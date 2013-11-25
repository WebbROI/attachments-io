class ProfileController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = current_user
    @emails = @user.emails.includes(:user_email_files).all

    if @user.token_expire? && !@user.has_refresh_token?
      flash[:error] = render_to_string partial: 'partials/messages/token_expire'
    end
  end

  def settings
    @settings = current_user.settings
    @profile = current_user.profile

    if request.patch?
      if (params[:user_settings] && @settings.update_attributes(settings_params)) ||
         (params[:user_profile] && @profile.update_attributes(profile_params))

        flash[:success] = 'Settings was successful updated'
      else
        flash[:error] = 'Sorry, something was wrong'
      end
    end
  end

  def update_token
    if current_user.has_refresh_token?
      redirect_to profile_path, flash: { error: 'You do not need update access token' }
    end

    if request.post?
      current_user_session.destroy
      redirect_to sign_in_google_path
    end
  end

  private

  def settings_params
    params.require(:user_settings).permit(:convert_files, :subject_in_filename)
  end

  def profile_params
    params.require(:user_profile).permit(:gender, :organization, :location, :plus, :twitter, :facebook)
  end

end
