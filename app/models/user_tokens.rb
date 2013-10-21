class UserTokens < ActiveRecord::Base
  belongs_to :user

  def formatted
    {
        access_token: access_token,
        refresh_token: refresh_token,
        issued_at: issued_at,
        expires_in: expires_in
    }
  end

  def token_expire?
    issued_at + expires_in.to_i < Time.now.to_i
  end
end
