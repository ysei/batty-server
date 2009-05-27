
# OpenIDログイン情報コントローラ
class Credentials::OpenIdController < ApplicationController
  before_filter :authentication
  before_filter :authentication_required
  before_filter :required_param_open_id_credential_id
  before_filter :specified_open_id_credential_belongs_to_login_user

  # GET /credential/open_id/:open_id_credential_id/delete
  def delete
    # nop
  end

  # POST /credential/open_id/:open_id_credential_id/destroy
  # TODO: 実装せよ

  private

  def required_param_open_id_credential_id(open_id_credential_id = params[:open_id_credential_id])
    @open_id_credential = OpenIdCredential.find_by_id(open_id_credential_id)
    if @open_id_credential
      return true
    else
      set_error("OpenIDログイン情報IDが正しくありません。")
      redirect_to(root_path)
      return false
    end
  end

  def specified_open_id_credential_belongs_to_login_user
    if @open_id_credential.user_id == @login_user.id
      return true
    else
      set_error("OpenIDログイン情報IDが正しくありません。")
      redirect_to(root_path)
      return false
    end
  end
end
