class UpdateGoogleChannelWorker
  include Sidekiq::Worker

  def perform
    # GoogleCalendarのChannelを順次参照
    GoogleChannel.find_each do |google_channel|
      google_channel.update
    end
    
    puts Date.today.to_time
    puts 'Sidekiq実行:GoogleChannel更新'
  end
end
