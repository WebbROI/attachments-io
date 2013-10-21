class DevController < ApplicationController
  def flush_all
    User.destroy_all
    redirect_to root_path, flash: { success: 'Success!' }
  end
end