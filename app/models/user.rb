class User < ActiveRecord::Base
  has_one :tokens, dependent: :destroy

  def self.create_with_omniauth(auth)
    create! do |user|
      user.uid = auth['uid']
      user.first_name = auth['info']['first_name']
      user.last_name = auth['info']['last_name']
      user.full_name = auth['info']['name']
      user.email = auth['info']['email']
    end
  end

  def update_tokens(params)
    tokens = tokens()

    puts params[:expires_at].to_i

    attributes = {
        token: params[:token],
        refresh_token: params[:refresh_token],
        expires_at: params[:expires_at].to_i
    }

    if tokens
      tokens.update_attributes(attributes)
    else
      tokens = create_tokens(attributes)
    end
  end
end
