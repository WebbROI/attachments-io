class SessionsController < ApplicationController
  skip_before_filter :authenticate_user!, only: :create
  skip_before_filter :verify_authenticity_token

  def create
    auth = request.env['omniauth.auth']
    puts auth.inspect
    puts auth[:credentials].inspect
    user = User.find_by_email(auth[:info][:email])

    if user
      unless auth[:credentials].empty?
        user.update_tokens(tokens_params)
      end
    else
      user = User.create_with_omniauth(user_params)
      if auth[:credentials].empty?
        return redirect_to '/auth/google_oauth2'
      else
        user.update_tokens(tokens_params)
      end
    end

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
    omni.require(:uid)
    omni.require(:info).permit(:first_name, :last_name, :full_name, :email)

    omni
  end

  def tokens_params
    omni = ActionController::Parameters.new(request.env['omniauth.auth'][:credentials])
    omni.permit(:token, :refresh_token, :expires_at)

    omni
  end
end
