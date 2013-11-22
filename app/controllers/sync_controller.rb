class SyncController < ApplicationController
  before_filter :authenticate_user!

  def start
    if current_user.now_synchronizes?
      redirect_to profile_path, flash: { error: 'You already have synchronization in process..' } and return
    end

    current_user.start_synchronization#(debug: true)
    redirect_to profile_path
  end
end
