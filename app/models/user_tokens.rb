class UserTokens < ActiveRecord::Base
  def formatted
    {
        access_token: access_token,
        refresh_token: refresh_token,
        issued_at: issued_at,
        expires_in: expires_in
    }
  end
end
