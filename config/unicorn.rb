#######################################
# For Production in heroku
#######################################

timeout 15
preload_app true

worker_processes 2

# whatever you had in your unicorn.rb file
@sidekiq_pid = nil

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
   
  puts("unicorn実行1") 
  puts(ENV['RAILS_ENV'])
  if ENV['RAILS_ENV'] == 'production' # Sidekiq関連はここ！【更新あり】
    puts("unicorn実行2") 
    if @sidekiq_pid == nil
      @sidekiq_pid = spawn("mkdir -p /app/tmp/pids && bundle exec sidekiq -c 2")
      puts('Spawned sidekiq #{@sidekiq_pid}')
    else
      puts("実行なし")
    end
    #@sidekiq_pid ||= spawn("mkdir -p /app/tmp/pids && bundle exec sidekiq -c 2")
    puts(@sidekiq_pid) 
    Rails.logger.info('Spawned sidekiq #{@sidekiq_pid}')
  end
end 


after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
