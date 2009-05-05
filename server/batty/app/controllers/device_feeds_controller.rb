
require "rss"

# デバイスフィード
class DeviceFeedsController < ApplicationController
  before_filter :required_param_device_token

  # GET /device/:device_token/energies.rdf
  def energies
    @energies = @device.energies.paginate(
      :order    => "energies.observed_at DESC, energies.id DESC",
      :page     => 1,
      :per_page => 10)

    rss = RSS::Maker.make("2.0") { |maker|
      maker.channel.title       = "batty::デバイス::#{@device.name}::エネルギー"
      maker.channel.description = "#{@device.name}のエネルギー履歴"
      maker.channel.link        = root_url # FIXME: URLを変更
      # FIXME: デバイスアイコンを出力

      @energies.each { |energy|
        item = maker.items.new_item
        item.link  = "http://batty.nayutaya.jp/device/#{@device.device_token}/" # FIXME: デバイスページのURLに変更
        item.title = "#{energy.observed_level}%"
        item.date  = energy.observed_at
      }
    }

    send_rss(rss)
  end

  # GET /device/:device_token/events.rdf
  def events
    @events = @device.events.paginate(
      :order    => "events.observed_at DESC, events.id DESC",
      :page     => 1,
      :per_page => 10)

    rss = RSS::Maker.make("2.0") { |maker|
      maker.channel.title       = "batty::デバイス::#{@device.name}::イベント"
      maker.channel.description = "#{@device.name}のイベント履歴"
      maker.channel.link        = root_url # FIXME: URLを変更
      # FIXME: デバイスアイコンを出力

      @events.each { |event|
        item = maker.items.new_item
        item.link  = "http://batty.nayutaya.jp/device/#{@device.device_token}/" # FIXME: デバイスページのURLに変更
        item.title = "#{event.observed_level}% #{event.trigger_operator_sign} #{event.trigger_level}%"
        item.date  = event.observed_at
      }
    }

    send_rss(rss)
  end

  private

  def required_param_device_token(device_token = params[:device_token])
    @device = Device.find_by_device_token(device_token)
    return true if @device

    render(:text => "", :status => 404)

    return false
  end
end