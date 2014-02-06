class SigninController < ApplicationController
  before_filter :not_authenticated_user!

  def google
    redirect_to '/auth/google'
  end

  def apps
    if params[:domain]
      redirect_to "/auth/google?hd=#{params[:domain]}"
    end
  end

  def error

  end
end
