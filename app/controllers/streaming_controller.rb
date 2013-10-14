class StreamingController < ApplicationController
  include ActionController::Live

  def events
    unless user_sign_in?
      return
    end

    response.headers['Content-Type'] = 'text/event-stream'

    @@puub.subscribe "user_#{current_user.id}" do |message|
      response.stream.write "event: #{message[:event]}\n"
      response.stream.write "data: #{message[:data].to_json}\n\n"
    end
  ensure
    response.stream.close
  end
end
