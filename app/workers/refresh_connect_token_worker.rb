class RefreshConnectTokenWorker
  include Sidekiq::Worker

  def perform
    # LS Connectのアクセストークンを順次参照
    ConnectToken.find_each do |connect_token|
      connect_token.refresh
    end
    
    puts Date.today.to_time
    puts 'Sidekiq実行:ConnectAccessToken更新'
  end
end
