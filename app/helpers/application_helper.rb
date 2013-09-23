module ApplicationHelper

  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if user_signed_in?
  end

  def user_signed_in?
    session[:user_id] && User.find_by_id(session[:user_id])
  end
end
