class ApplicationController < ActionController::Base
  require 'puub'
  require 'google/API'

  protect_from_forgery with: :exception
  before_filter :puub
  before_filter :initialize_user
  helper_method :current_user_session, :current_user, :user_signed_in?

  private
    def current_user_session
      return @current_user_session if defined? @current_user_session
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined? @current_user
      @current_user = current_user_session && current_user_session.user
    end

    def initialize_user
		@user ||= current_user_session && current_user_session.user
    end

    def user_signed_in?
      !!current_user
    end

    def authenticate_user!
      redirect_to welcome_path, flash: { error: 'You need sign in to view this page' } unless user_signed_in?
    end

    def not_authenticated_user!
      redirect_to welcome_path, flash: { error: 'This page only for guests' } if user_signed_in?
    end

    def puub
      @@puub ||= Puub.instance
    end
end
