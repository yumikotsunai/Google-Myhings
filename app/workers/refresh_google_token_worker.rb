class RefreshGoogleTokenWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  # 1時間以内に定期実行⇒とりあえず10毎
  #recurrence do
  #  minutely(50)
  #end
  
  #def perform
  #  # GoogleAccountのアクセストークンを順次参照
  #  GoogleToken.find_each do |google_token|
  #    google_token.refresh
  #  end
    
  #  puts DateTime.now　
  #  puts 'Sidekiq実行:GoogleAccessToken更新'
  #end
end
