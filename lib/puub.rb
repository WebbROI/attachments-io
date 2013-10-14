require 'singleton'

class Puub
  include Singleton

  def initialize
    super

    @publish ||= Hash.new
  end

  def publish(channel, data)
    @publish[channel] ||= Array.new
    @publish[channel] << data
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

  def clear_channel(channel)
    @publish[channel].clear unless @publish[channel].empty?
  end

  def clear_all
    @publish.clear
  end

end