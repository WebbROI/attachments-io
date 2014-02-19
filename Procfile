web: bundle exec unicorn_rails -D -c config/unicorn.rb -E production
worker: bundle exec rake environment resque:work QUEUE=* COUNT=10 RAILS_ENV=production