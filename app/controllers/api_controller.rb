class ApiController < ApplicationController
  before_filter :authenticate_user!

  def sync
    if Synchronization::Process.check(current_user.id)
      sync = Synchronization::Process.get(current_user.id)
    else
      sync = { status: 'waiting' }
    end

    respond_to do |format|
      format.json { render json: sync }
    end
  end

  def me
    @user = current_user
    user = @user.as_json
    user[:sync_status] = @user.now_synchronizes? ? true : false

    user.delete('uid')
    user.delete('persistence_token')
    user.delete('login_count')
    user.delete('current_login_at')
    user.delete('current_login_ip')
    user.delete('last_login_at')
    user.delete('last_login_ip')
    user.delete('created_at')
    user.delete('updated_at')

    respond_to do |format|
      format.json { render json: user }
    end
  end

  def emails
    puts params

    @emails = current_user.emails

    @emails = @emails.limit(params[:limit].to_i) unless params[:limit].nil?
    @emails = @emails.offset(params[:offset].to_i) unless params[:offset].nil?

    @emails = @emails.includes(:email_files)
  end
end
