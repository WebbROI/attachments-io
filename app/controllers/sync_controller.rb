class SyncController < ApplicationController
  before_filter :authenticate_user!

  def start
    if current_user.now_synchronizes?
      redirect_to profile_path, flash: { error: 'You already have synchronization in process..' } and return
    end

    current_user.start_synchronization(debug: true)
    redirect_to profile_path
  end

  def resync
    #if Rails.env.production?
    #  redirect_to profile_path
    #end

    current_user.emails.destroy_all
    current_user.update_attribute(:last_sync, nil)

    items = current_user.api.load_files(title: IO_ROOT_FOLDER, is_root: true).data.items

    unless items.empty?
      current_user.api.delete_file(items.first.id)
    end

    redirect_to sync_start_path
  end
end
