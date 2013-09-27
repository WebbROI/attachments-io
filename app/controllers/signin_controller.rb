class SigninController < ApplicationController
  before_filter :not_authenticated_user!

  def google
    redirect_to '/auth/google'
  end

  def apps
  end
end
