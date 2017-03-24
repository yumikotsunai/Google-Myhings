class UpdateGoogleChannelWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  # 1週間以内に定期実行⇒とりあえず6日毎#実験的に1時間ごと
  recurrence do
    #daily(6)
    #hourly(1)
    minutely(10)
  end
  
  def perform
    # GoogleCalendarのChannelを順次参照
    GoogleChannel.find_each do |google_channel|
      google_channel.update
    end
    
    puts DateTime.now
    puts 'Sidekiq実行:GoogleChannel更新'
  end
end
