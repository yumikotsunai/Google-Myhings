class UpdateGoogleChannelWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  # 1週間以内に定期実行⇒とりあえず6日毎
  recurrence do
    #daily(6)
    minutely(10)
  end
  
  def perform
    # GoogleCalendarのChannelを順次参照
    puts 'google_workerテスト'
    puts DateTime.now
    
    #GoogleChannel.find_each do |google_channel|
    #  google_channel.update
    #end
    
    #puts DateTime.now
    #puts 'Sidekiq実行:GoogleChannel更新'
  end
end
