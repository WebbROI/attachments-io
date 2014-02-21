Dir["#{Rails.root}/app/workers/*.rb"].each { |file| require file }

Resque::Server.use(Rack::Auth::Basic) do |user, password|
  password == 'Chargers36@'
end

unless Rails.env.development?
  Resque.redis = Redis.new(password: 'Chargers36!@')
end