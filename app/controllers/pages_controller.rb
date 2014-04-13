class PagesController < ApplicationController
  layout 'no-wrapper'

  def home
    if user_signed_in?
      redirect_to profile_path
    end
  end

  def une
    if params[:domain]
      redirect_to "/auth/google?hd=#{params[:domain]}"
    else
      redirect_to '/auth/google'
    end
  end
end
