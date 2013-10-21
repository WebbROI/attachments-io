class UserMailer < ActionMailer::Base
  default from: 'no-reply@attachments.io'

  def welcome_email(user)
    @user = user
    mail(to: 'andrew@webbroi.com', subject: 'Hello!')
  end
end
