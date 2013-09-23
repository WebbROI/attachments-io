class User < ActiveRecord::Base

  def domain
    email.split('@').last
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.uid = auth['uid']
      user.first_name = auth['info']['first_name']
      user.last_name = auth['info']['last_name']
      user.full_name = auth['info']['name']
      user.email = auth['info']['email']
    end
  end
end
