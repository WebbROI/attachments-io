web: bundle exec unicorn -D -c /home/rails/current/config/unicorn.rb -E production -p 8080
worker: bundle exec rake environment resque:work QUEUE=* COUNT=10 RAILS_ENV=production