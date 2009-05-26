# -*- coding: utf-8 -*-

# OpenID認証
class Auth::OpenIdController < ApplicationController
  verify(
    :method => :post,
    :render => {:text => "Method Not Allowed", :status => 405},
    :only   => [:login])

  # GET /auth/open_id
  def index
    session[:user_id] = nil
  end

  # POST /auth/open_id/login
  # GET  /auth/open_id/login
  def login
    openid_url = params[:openid_url]

    authenticate_with_open_id(openid_url) { |result, identity_url, sreg|
      redirect_by_result(result, identity_url, sreg)
    }
  end

  private

  def successful_login
    session[:user_id] = @current_user.id
    flash[:notice] = "ログインしました。"
    redirect_to(root_path)
  end

  def failed_login(message)
    flash[:error] = message
    redirect_to(root_path)
  end

  def redirect_by_result(result, identity_url, sreg)
    case result.status
    when :missing
      failed_login "OpenID サーバが見つかりませんでした。"
    when :invalid
      failed_login "OpenID が不正です。"
    when :canceled
      failed_login "OpenID の検証がキャンセルされました。"
    when :failed
      failed_login "OpenID の検証が失敗しました。"
    when :successful
      @current_user = OpenIdCredential.find_by_identity_url(identity_url).try(:user)
      if @current_user
        successful_login
      else
        flash[:notice] = "OpenID がまだ登録されていません。"
        redirect_to(:controller => "signup/open_id", :action => "index")
      end
    end
  end
end