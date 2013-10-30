class PagesController < ApplicationController
  layout 'no-wrapper'

  def home
    if user_signed_in?
      redirect_to profile_path
    end
  end
end
