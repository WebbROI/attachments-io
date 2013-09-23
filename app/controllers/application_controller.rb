class ApplicationController < ActionController::Base

  # TODO: fix it
  require 'google/client'
  require 'google/contact'
  require 'google/user'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authenticate_user!
    redirect_to '/auth/google_apps' unless user_signed_in?
  end

  private

  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if user_signed_in?
  end

  def user_signed_in?
    session[:user_id] && User.find_by_id(session[:user_id])
  end
end
