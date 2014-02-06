class User < ActiveRecord::Base
  require 'start_synchronization'
  require 'synchronization/run'

  has_one :user_tokens, dependent: :destroy
  has_one :user_profile, dependent: :destroy
  has_one :user_settings, dependent: :destroy
  has_one :user_synchronization, dependent: :destroy
  has_one :filter, dependent: :destroy
  has_many :emails, dependent: :destroy

  acts_as_authentic

  alias :tokens :user_tokens
  alias :settings :user_settings
  alias :profile :user_profile
  alias :filters :filter
  alias :sync :user_synchronization

  def to_s
    email
  end

  def self.create_with_omniauth(auth)
    user = create! do |user|
      user.uid = auth[:uid]
      user.first_name = auth[:info][:first_name]
      user.last_name = auth[:info][:last_name]
      user.email = auth[:info][:email]
      user.picture = auth[:info][:image]
    end

    user.initialize_profile
    user.initialize_settings
    user.initialize_filters
    user.initialize_synchronization
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

  def initialize_settings
    create_user_settings
  end

  def initialize_filters
    create_filter
  end

  def initialize_synchronization
    create_user_synchronization({ status: Synchronization::WAITING })
  end

  def files_for_sync
    files = {}
    emails.includes(:email_files).each do |email|
      email.files.each do |file|
        files[file.filename] = { size: file.size, link: file.link, label: email.label }
      end
    end

    files
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

  def start_synchronization(params = {}, force = false)
    return if now_synchronizes? && !force
    sync.inprocess!

    Resque.enqueue_to("sync_user_#{self.id}_queue", StartSynchronization, self.id, params)
  end

  def now_synchronizes?
    sync.inprocess?
  end

  def fix_sync
    sync.update_attributes({ status: Synchronization::WAITING,
                             previous_status: Synchronization::FIXED })
  end

  #
  # Helpers
  #

  def update_tokens(attributes)
    tokens = user_tokens

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
