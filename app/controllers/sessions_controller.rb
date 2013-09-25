class SessionsController < ApplicationController
  skip_before_filter :authenticate_user!, only: :create
  skip_before_filter :verify_authenticity_token

  def create
    auth = request.env['omniauth.auth']
    puts auth.inspect
    puts auth[:credentials].inspect
    user = User.find_by_email(auth[:info][:email])

    if user

      puts 'USER FOUNDED'

      if auth[:credentials].empty?
        puts 'WE DON\'T HAVE CREDENTAILS :('
      else
        puts 'WE HAVE CREDENTAILS'
      end
    else
      user = User.create_with_omniauth(user_params)
      puts 'USER NOT FOUND'

      if auth[:credentials].empty?
        puts 'WE DON\'T HAVE CREDENTAILS :('

        return redirect_to '/auth/google_oauth2'
      else
        puts 'WE HAVE CREDENTAILS'
      end
    end

    #puts auth.inspect
    #puts auth['credentials'].inspect
    #user = User.find_by_uid(auth['uid']) || User.create_with_omniauth(user_params)
    #session[:user_id] = user.uid
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
