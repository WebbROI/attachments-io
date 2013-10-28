class User < ActiveRecord::Base
  has_one :user_tokens, dependent: :destroy
  has_one :user_profile, dependent: :destroy
  has_one :user_settings, dependent: :destroy
  has_one :user_filter, dependent: :destroy
  has_many :user_synchronizations, dependent: :destroy

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

  def initialize_settings
    create_user_settings({
                             subject_folder: false,
                             convert_files: false,
                             filename_format: UserSynchronization::DEFAULT_FILENAME_FORMAT
                         })
  end

  def initialize_profile
    info = load_info
    profile = build_user_profile

    profile.gender = info.gender if defined? info.gender
    profile.plus = info.url if defined? info.url

    if defined? info.organizations
      organization = Array.new

      info.organizations.each do |item|
        organization << "#{item.name}, #{item.title}"
      end

      profile.organization = organization.join('; ')
    end

    if defined? info.places_lived
      location = Array.new

      info.places_lived.each do |item|
        location << item.value
      end

      profile.location = location.join('; ')
    end

    profile.save!
  end

  def initialize_filters
    create_user_filter
  end

  #
  # Aliases
  #

  def tokens
    user_tokens
  end

  def synchronizations
    user_synchronizations
  end

  def settings
    user_settings
  end

  def profile
    user_profile
  end

  def filters
    user_filter
  end

  #
  # Google API
  #

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

  def token_expire?
    user_tokens.token_expire?
  end

  def has_refresh_token?
    !!user_tokens.refresh_token
  end

  #
  # Synchronization
  #

  def start_synchronization(debug = false)
    sync = UserSynchronization.create!({ user_id: id, status: UserSynchronization::STATUS_INPROCESS, started_at: Time.now.to_i })

    if token_expire? && !has_refresh_token?
      return false
    end

    if debug
      sync.start
    else
      Thread.new do
        sync.start
      end
    end

    sync
  end

  def now_synchronizes?
    false
  end

  #
  # Helpers
  #

  def update_tokens(attributes)
    tokens = user_tokens()

    if tokens
      tokens.update_attributes(attributes)
    else
      create_user_tokens(attributes)
    end
  end

  def profile_picture(options = {})
    ActionController::Base.helpers.image_tag(picture, options)
  end
end
