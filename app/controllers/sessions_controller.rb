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
      tokens = {}
      tokens[:issued_at] = Time.now.to_i
      tokens[:expires_in] = auth[:credentials][:expires_at].to_i - tokens[:issued_at]
      tokens[:access_token] = auth[:credentials][:token]

      if auth[:credentials][:refresh_token]
        tokens[:refresh_token] = auth[:credentials][:refresh_token]
      end

      user.update_tokens(tokens)
    end

    if first_login
      user.initialize_profile
      user.initialize_settings
      user.initialize_filters
      user.initialize_synchronization

      # push user to mailchimp
      gb = Gibbon::API.new('fd15479bff9f2f46d331f063dc69f506-us3')
      gb.throws_exceptions = false
      gb.lists.subscribe({
                             id: '1af018ddaa',
                             email: { email: user.email },
                             merge_vars: { FNAME: user.first_name, LNAME: user.last_name },
                             double_optin: false,
                             send_welcome: true
                         })

      redirect_to sync_start_path, flash: { success: 'Welcome to Attachments.io! We are syncing your emails and attachments for the last 2 weeks, and all future emails. <a href="https://mail.google.com/mail/u/0/#search/attachments.io" target="_blank">Please verify your account</a>. And for more information on syncing your emails from the beginning of time, <a href="http://attachments.io/contact/" target="_blank">please contact us</a>.' }
    else
      redirect_to root_path, flash: { success: "You have signed in as #{user.first_name} #{user.last_name} (#{user.email})" }
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = 'You have successfully logged out!'
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
