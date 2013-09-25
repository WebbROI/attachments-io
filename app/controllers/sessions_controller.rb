class SessionsController < ApplicationController
  skip_before_filter :authenticate_user!, only: :create
  skip_before_filter :verify_authenticity_token

  def create
    auth = request.env['omniauth.auth']
    puts auth.inspect
    puts auth['info'].inspect
    puts auth['credentials'].inspect
    puts auth['credentials']['token'].inspect
    user = User.find_by_uid(auth['uid']) || User.create_with_omniauth(user_params)
    session[:user_id] = user.uid
    redirect_to root_path, notice: 'Signed in!'
  end

  def destroy
    reset_session
    redirect_to root_path, notice: 'Signed out!'
  end

  private

  def user_params
    omni = ActionController::Parameters.new(request.env['omniauth.auth'])

    puts omni.inspect

    omni.require(:uid)
    omni.require(:info).permit(:first_name, :last_name, :full_name, :email)

    omni
  end
end
