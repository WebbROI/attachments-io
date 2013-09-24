class SigninController < ApplicationController
  skip_before_filter :authenticate_user!

  def index

  end

  def apps
    if params[:domain]
      redirect_to "/auth/google_apps?domain=#{params[:domain]}"
    end
  end

  def google
  end

  def failure
    puts params.inspect
  end
end
