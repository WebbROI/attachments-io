web: bundle exec unicorn -D -c config/unicorn.rb -E production
worker: bundle exec rake environment resque:work QUEUE=* COUNT=10 RAILS_ENV=production