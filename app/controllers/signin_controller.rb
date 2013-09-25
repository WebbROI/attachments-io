class SigninController < ApplicationController
  skip_before_filter :authenticate_user!

  def apps
    if user_signed_in?
      redirect_to root_path
    end

    if params[:domain]
      redirect_to "/auth/google_apps?domain=#{params[:domain]}"
    end
  end

  def google
    redirect_to '/auth/google_oauth2'
  end

  def failure
    puts params.inspect
    render text: 'Sorry, we have an error'
  end
end
