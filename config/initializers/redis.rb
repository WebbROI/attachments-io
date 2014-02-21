if Rails.env.development?
  $redis = Redis.new
else
  $redis = Redis.new(password: 'Chargers36!@')
end