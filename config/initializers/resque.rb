Dir["#{Rails.root}/app/workers/*.rb"].each { |file| require file }

if Rails.env.development?
  Resque::Server.use(Rack::Auth::Basic) do |user, password|
    password == 'Chargers36@'
  end
else
  Resque::Server.use(Rack::Auth::Basic) do |user, password|
    password == 'Chargers36!@'
  end
end