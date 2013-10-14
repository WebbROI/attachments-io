class ProfileController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = current_user
    @syncs = @user.synchronizations
  end

  def settings
    @settings = current_user.settings

    @@puub.publish("user_#{current_user.id}", { event: 'message', data: 'Opened user settings' })

    if request.patch?
      if @settings.update_attributes(settings_params)
        redirect_to profile_path, flash: { success: 'Settings was successful updated' }
      end
    end
  end

  private

  def settings_params
    params.require(:user_settings).permit(:subject_folder, :convert_files)
  end

end
