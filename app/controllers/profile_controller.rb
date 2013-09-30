class ProfileController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = current_user
    @user_info = @user.load_info
    puts @user_info.inspect
  end

  def edit
  end
end
