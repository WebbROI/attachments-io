module ApplicationHelper

  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if user_signed_in?
  end

  def user_signed_in?
    session[:user_id] && User.find_by_id(session[:user_id])
  end

  def bootstrap_class_for flash_type
    case flash_type
      when :success
        'alert-success'
      when :error
        'alert-error'
      when :alert
        'alert-block'
      when :notice
        'alert-info'
      else
        flash_type.to_s
    end
  end
end
