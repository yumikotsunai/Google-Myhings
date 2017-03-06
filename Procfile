web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: mkdir -p tmp/pids && bundle exec sidekiq -C config/sidekiq.yml