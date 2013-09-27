class SessionsController < ApplicationController
  before_filter :authenticate_user!, only: :destroy
  before_filter :not_authenticated_user!, only: :create_google

  def create_google
    auth = request.env['omniauth.auth']
    user = User.find_by_email(auth[:info][:email]) || User.create_with_omniauth(user_params)

    unless auth[:credentials].empty?
      user.update_tokens(tokens_params)
    end

    UserSession.create(user, true)
    redirect_to root_path, flash: { success: 'You successful login!' }
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = 'You successful logout!'
    redirect_to root_path
  end

  private
    def user_params
      omni = ActionController::Parameters.new(request.env['omniauth.auth'])
      omni.require(:uid)
      omni.require(:info).permit(:first_name, :last_name, :full_name, :email, :image)

      omni
    end

    def tokens_params
      omni = ActionController::Parameters.new(request.env['omniauth.auth'][:credentials])
      omni.permit(:token, :refresh_token, :expires_at)
    end
end
