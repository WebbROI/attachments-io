class StreamingController < ApplicationController
  include ActionController::Live

  def events
    response.headers['Content-Type'] = 'text/event-stream'

    response.stream.write "event: ping\n"
    response.stream.write "data: pong\n\n"

    if user_signed_in?
      $puub.subscribe_to_user current_user do |message|
        response.stream.write "event: #{message['event']}\n"
        response.stream.write "data: #{message['data']}\n\n"
      end
    end
  ensure
    response.stream.close
  end
end
