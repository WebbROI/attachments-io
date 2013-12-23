class DevController < ApplicationController
  include ActionController::Live

  #def flush_all
  #  User.destroy_all
  #  redirect_to root_path
  #end

  def pub
    Puub.instance.publish('time', 'Time.now')
    render text: :hello
  end

  def sub
    Puub.instance.subscribe 'time' do |message|
      puts message.inspect
    end

    render text: :world
  end
end