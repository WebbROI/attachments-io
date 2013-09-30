class SyncController < ApplicationController
  before_filter :authenticate_user!

  def start
    unless current_user.synchronizations.inprocess.empty?
      return redirect_to profile_path, flash: { error: 'You can not start two synchronizations at one time.' }
    end

    sync = current_user.start_synchronization
    redirect_to sync_details_path(sync.id), flash: { success: 'Synchronization was successful started!' }
  end

  def details
    @sync = UserSynchronization.find_by_id(params[:id])

    if @sync.nil? || @sync.user != current_user
      redirect_to profile_path
    end
  end
end
