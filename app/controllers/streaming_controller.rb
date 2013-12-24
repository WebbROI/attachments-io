class StreamingController < ApplicationController
  include ActionController::Live

  def events
    response.headers['Content-Type'] = 'text/event-stream'

    if user_signed_in?
      $puub.subscribe_to_user current_user do |message|
        response.stream.write "event: #{message['event']}\n"
        response.stream.write "data: #{message['data'].to_json}\n\n"
      end
    end
  ensure
    response.stream.close
  end
end
