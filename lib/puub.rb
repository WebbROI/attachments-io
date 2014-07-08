class Puub
  def publish(channel, data)
    messages = $redis.get(channel_name(channel))

    if messages.nil?
      messages = []
    else
      messages = decode_data(messages)
    end

    messages << [data, Time.now.to_i]
    $redis.set(channel_name(channel), encode_data(messages))
  end

  def subscribe(channel, &block)
    messages = $redis.get(channel_name(channel))
    return if messages.nil?

    messages = decode_data(messages)
    messages.each do |message|
      next if Time.now.to_i - message.last > 3.seconds
      block.call(message.first)
    end
  ensure
    clear_channel(channel_name(channel))
  end

  def publish_for_user(user, data)
    publish("user:#{user.id}", data)
  end

  def subscribe_to_user(user, &block)
    subscribe("user:#{user.id}", &block)
  end

  def clear_channel(channel)
    $redis.del(channel)
  end

  private

  PREFIX = 'streaming'

  def encode_data(value)
    ActiveSupport::JSON.encode(value)
  end

  def decode_data(value)
    ActiveSupport::JSON.decode(value)
  end

  def channel_name(channel)
    "#{Rails.env}:#{PREFIX}:#{channel}"
  end
end