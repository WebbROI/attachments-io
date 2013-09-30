class SigninController < ApplicationController
  before_filter :not_authenticated_user!

  def google
    redirect_to '/auth/google'
  end

  def apps
    if params[:domain]
      redirect_to "/auth/google?hd=#{params[:domain]}"
    end

    #openid_parameters = {
    #    #required: [ :nickname, :email ],
    #
    #    'openid.ns' => 'http://specs.openid.net/auth/2.0',
    #    'openid.claimed_id' => 'http://specs.openid.net/auth/2.0/identifier_select',
    #    'openid.realm' => 'http://localhost:3000/',
    #
    #    'openid.ns.ui' => 'http://specs.openid.net/extensions/ui/1.0',
    #    'openid.ui.mode' => 'popup',
    #    'openid.ui.icon' => 'true',
    #
    #    'openid.ns.ax' => 'http://openid.net/srv/ax/1.0',
    #    'openid.ax.mode' => 'fetch_request',
    #    'openid.ax.required' => 'country+email+firstname+lastname',
    #
    #    'openid.ns.ext2' => 'http://specs.openid.net/extensions/oauth/1.0',
    #    'openid.ext2.consumer' => 'localhost:3000',
    #    'openid.ext2.scope' => 'https://mail.google.com/+'
    #}
    #
    #authenticate_with_open_id('https://www.google.com/accounts/o8/id', openid_parameters) do |result, identity_url, registration|
    #  puts 'result'
    #  puts result.inspect
    #
    #  case result.status
    #    when :missing
    #      flash[:error] = 'Sorry, the OpenID server couldn\'t be found'
    #    when :invalid
    #      flash[:error] = 'Sorry, but this does not appear to be a valid OpenID'
    #    when :canceled
    #      flash[:error] = 'OpenID verification was canceled'
    #    when :failed
    #      flash[:error] = 'Sorry, the OpenID verification failed'
    #    when :successful
    #      puts 'identy'
    #      puts identity_url.inspect
    #      puts 'ax'
    #      puts registration.inspect
    #  end
    #end
  end
end
