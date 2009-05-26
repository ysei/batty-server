
# ユーザ設定
class SettingsController < ApplicationController
  before_filter :authentication
  before_filter :authentication_required

  # GET /settings
  def index
    # nop
  end

  def get_nickname
    render(:text => @login_user.nickname)
  end

  def set_nickname
    @login_user.nickname = params[:value]
    if @login_user.save
      render(:text => ERB::Util.h(@login_user.nickname))
    else
      message = @login_user.errors.on(:nickname)
      message = message.join(", ") if message.kind_of?(Array)
      render(:text => ERB::Util.h(message), :status => 400)
    end
  end
end
