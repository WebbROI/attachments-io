class ProfileController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = current_user
    @syncs = @user.synchronizations
  end

  def edit
  end
end
