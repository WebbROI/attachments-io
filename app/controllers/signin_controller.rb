class SigninController < ApplicationController
  before_filter :not_authenticated_user!

  def google
    redirect_to '/auth/google'
  end

  def apps
    if params[:domain]
      redirect_to "/auth/google?hd=#{params[:domain]}"
    end
  end

  def error
    logger = Logger.new('log/auth_errors.log')
    logger.error '============================================================='
    logger.error "Date: #{Time.now.to_formatted_s(:long)}"
    logger.error "Parameters: #{params.inspect}"
  end
end
