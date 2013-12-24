class DevController < ApplicationController

  #def flush_all
  #  User.destroy_all
  #  redirect_to root_path
  #end

  def pub
    $puub.clear_channel("user:#{current_user.id}")
    $puub.publish_for_user(current_user, { event: 'message', data: { message: "hello, guys, now #{Time.now}" } })
    render text: :hello
  end
end