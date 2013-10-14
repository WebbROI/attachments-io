class SyncController < ApplicationController
  before_filter :authenticate_user!

  def start
    if current_user.now_synchronizes?
      redirect_to profile_path, flash: { error: 'You already have synchronization in process..' } and return
    end

    sync = current_user.start_synchronization
    redirect_to sync_details_path(sync)
  end

  def details
    @sync = UserSynchronization.find_by_id(params[:id])

    if @sync.nil? || @sync.user != current_user
      redirect_to profile_path, flash: { error: 'Not found' }
    end
  end
end
