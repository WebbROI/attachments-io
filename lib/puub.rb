require 'singleton'

class Puub
  include Singleton

  def initialize
    super

    @publish ||= {}
  end

  def publish(channel, data)
    @publish[channel] ||= []
    @publish[channel] << data
  end

  def publish_for_user(user, data)
    publish("user_#{user.id}", data)
  end

  def subscribe(channel, &block)
    if @publish[channel].nil? || @publish[channel].empty?
      return nil
    end

    @publish[channel].each do |data|
      block.call(data)
    end

    @publish[channel].clear
  end

  def subscribe_to_user(user, &block)
    subscribe("user_#{user.id}", &block);
  end

  def clear_channel(channel)
    @publish[channel].clear unless @publish[channel].empty?
  end

  def clear_all
    @publish.clear
  end

  private

  @publish

end