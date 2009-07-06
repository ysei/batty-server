
require "uri"
require "net/http"
require "ipaddr"

# HTTPアクション実行
class HttpActionExecutor
  WebHookDispatcher.open_timeout = 5
  WebHookDispatcher.read_timeout = 5
  WebHookDispatcher.user_agent   = "batty (http://batty.nayutaya.jp)"
  WebHookDispatcher.acl_with {
    allow :all
    deny  :addr => "127.0.0.0/8"
    deny  :addr => IPSocket.getaddress(Socket.gethostname).sub(/%.+\z/, "")
  }

  OpenTimeout = 5
  ReadTimeout = 5
  UserAgent   = "batty (http://batty.nayutaya.jp)".freeze

  DenyNetworks = [
    IPAddr.new("127.0.0.0/8"),
    IPAddr.new(IPSocket.getaddress(Socket.gethostname).sub(/%.+\z/, "")),
  ].freeze

  def initialize(options = {})
    options = options.dup
    @url         = options.delete(:url)         || nil
    @http_method = options.delete(:http_method) || nil
    @post_body   = options.delete(:post_body)   || nil
    raise(ArgumentError) unless options.empty?
  end

  attr_accessor :url, :http_method, :post_body

  def self.from(http_action)
    return self.new(
      :url         => http_action.url,
      :http_method => (http_action.http_method.blank? ? nil : http_action.http_method.downcase.to_sym),
      :post_body   => http_action.body)
  end

  def self.build_exectors(event)
    trigger = event.trigger
    return [] unless trigger

    keywords = NoticeFormatter.format_event(event)
    return trigger.http_actions.enable.map { |http_action|
      HttpActionExecutor.from(http_action).replace(keywords)
    }
  end

  def self.allowed_host?(host)
    name, aliases, type, *addresses = TCPSocket.gethostbyname(host)
    return addresses.
      map  { |ipaddr| IPAddr.new(ipaddr.sub(/%.+\z/, "")) }.
      all? { |ipaddr| DenyNetworks.none? { |network| network.include?(ipaddr) } }
  end

  def replace(keywords)
    url       = NoticeFormatter.replace_keywords(self.url,       keywords) if self.url
    post_body = NoticeFormatter.replace_keywords(self.post_body, keywords) if self.post_body
    return self.class.new(
      :url         => url,
      :http_method => self.http_method,
      :post_body   => post_body)
  end

  def execute
    dispatcher = WebHookDispatcher.new
    req =
      case @http_method
      when :head then WebHookDispatcher::Request::Head.new(URI.parse(self.url))
      when :get  then WebHookDispatcher::Request::Get.new(URI.parse(self.url))
      when :post then WebHookDispatcher::Request::Post.new(URI.parse(self.url), self.post_body)
      else raise("invalid http method")
      end

    ret = dispatcher.request(req)
    case ret.status
    when :success then return {:success => ret.success?, :message => "#{ret.http_code} #{ret.message}"}
    when :failure then return {:success => ret.success?, :message => "#{ret.http_code} #{ret.message}"}
    when :denied  then return {:success => false, :message => "connection refused."}
    when :timeout then return {:success => false, :message => "timeout."}
    when :refused then return {:success => false, :message => "connection refused."}
    when :reset   then return {:success => false, :message => "connection reset by peer."}
    when :error   then return {:success => false, :message => ret.message}
    end
  end

  def to_hash
    return {
      :url         => self.url,
      :http_method => self.http_method,
      :post_body   => self.post_body,
    }
  end

  protected

  def create_http_request
    klass =
      case @http_method
      when :head then Net::HTTP::Head
      when :get  then Net::HTTP::Get
      when :post then Net::HTTP::Post
      else raise("invalid http method")
      end

    request = klass.new(URI.parse(@url).request_uri)
    request.body = @post_body if @http_method == :post
    request["User-Agent"] = UserAgent

    return request
  end

  def create_http_connector
    uri  = URI.parse(@url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = OpenTimeout
    http.read_timeout = ReadTimeout

    return http
  end
end
