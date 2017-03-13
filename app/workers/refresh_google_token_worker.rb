class RefreshGoogleTokenWorker
  include Sidekiq::Worker

  def perform
    # GoogleAccountのアクセストークンを順次参照
    GoogleToken.find_each do |google_token|
      google_token.refresh
    end
    
    puts Date.today.to_time
    puts 'Sidekiq実行:GoogleAccessToken更新'
  end
end
