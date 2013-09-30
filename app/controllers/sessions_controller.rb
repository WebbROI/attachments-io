class SessionsController < ApplicationController
  before_filter :authenticate_user!, only: :destroy
  before_filter :not_authenticated_user!, only: :create_google

  def create_google
    first_login = false
    auth = request.env['omniauth.auth']
    user = User.find_by_email(auth[:info][:email])

    if user.nil?
      user = User.create_with_omniauth(user_params)
      first_login = true
    else
      UserSession.create(user, true)
    end

    unless auth[:credentials].empty?
      issued_at = Time.now.to_i
      expires_in = auth[:credentials][:expires_at].to_i - issued_at

      user.update_tokens({ access_token: auth[:credentials][:token],
                           issued_at: issued_at,
                           expires_in: expires_in })
    end

    if first_login
      # TODO: add load information
      # @user.load_info

      redirect_to root_path, flash: { success: 'Thank you for using our service! Synchronization was started!' }
    else
      redirect_to root_path, flash: { success: 'You successful login!' }
    end
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
end
