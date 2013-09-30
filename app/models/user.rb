class User < ActiveRecord::Base
  has_one :user_tokens, dependent: :destroy

  acts_as_authentic

  def self.create_with_omniauth(auth)
    create! do |user|
      user.uid = auth[:uid]
      user.first_name = auth[:info][:first_name]
      user.last_name = auth[:info][:last_name]
      user.email = auth[:info][:email]
      user.picture = auth[:info][:image]
    end
  end

  def update_tokens(attributes)
    tokens = user_tokens()

    if tokens
      tokens.update_attributes(attributes)
    else
      create_user_tokens(attributes)
    end
  end

  def profile_picture(width = nil, height = nil, options = nil)
    if options.nil?
      options = { width: width, height: height }
    else
      options.merge!({ width: width, height: height })
    end

    ActionController::Base.helpers.image_tag(picture, options)
  end

  def tokens
    user_tokens
  end

  def api
    return @user_api if defined? @user_api
    @user_api = Google::API.new(tokens: tokens.formatted)

    if @user_api.update_token!
      tokens.update_attributes(@user_api.tokens)
    end

    @user_api
  end

  def load_info
    api.execute(
        api_method: api.load_api('plus').people.get,
        parameters: { userId: 'me' }
    ).data
  end
end
