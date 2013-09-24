class WelcomeController < ApplicationController
  # before_filter :authenticate_user!

  def index
    if user_signed_in?
      Google::User.all(current_user.domain)
    end
  end
end
