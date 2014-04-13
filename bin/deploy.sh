#!/bin/sh

cd "`dirname "$0"`/.."

echo "Running: git pull"
git pull

echo "Running: bundle install"
bundle install --quiet

echo "Running: rake db:migrate"
bundle exec rake db:migrate RAILS_ENV=production

echo "Running: rake assets:precompile"
bundle exec rake assets:precompile RAILS_ENV=production

echo "Restart server.."
touch tmp/restart.txt

echo "Successfuly updated!\n"
