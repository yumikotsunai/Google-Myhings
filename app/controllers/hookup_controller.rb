require 'http'
require 'google/api_client'
require 'date'

#GoogleCalendarのAOuth認証
class HookupController < ApplicationController
  
  # この↓一文がないとCSRF(Cross-Site Request Forgery)チェックでこけるので、APIをやりとりしているControllerには必要
  skip_before_filter :verify_authenticity_token
  
  #kke.remotelock@gmail.com
  @@googleAccountId = APP_CONFIG["google"]["user_name"]
  
  #クライアントID,クライアントシークレット,承認済みのリダイレクトURI,カレンダーIDを入力
  def setup
  end
  
  #上記変数を受取る
  def getcode
    
    @@clientId = params[:clientId]
    @@clientSecret = params[:clientSecret]
    @@calendarId = params[:calendarId]
    @@redirectUri = params[:redirectUri]
    
    #以下だと、入力文字列が認識されないようなのでコメントアウト
    #@@clientId = APP_CONFIG["google"]["client"] || params[:clientId].presence
    #@@clientSecret = APP_CONFIG["google"]["secret"] || params[:clientSecret]
    #@@calendarId = APP_CONFIG["google"]["calendar_id"] || params[:calendarId]
    #@@redirectUri = APP_CONFIG["webhost"]+'hookup/callback' || params[:redirectUri]
    
    #GoogleAccountテーブルに値を保存
    googleAccount = GoogleAccount.new(account_id: @@googleAccountId, client_id: @@clientId, client_secret: @@clientSecret, calendar_id:@@calendarId, redirect_uri:@@redirectUri )
    googleAccount.save
    
    #google認証のURLにリダイレクト
    url = 'https://accounts.google.com/o/oauth2/auth?client_id=' + @@clientId + '&redirect_uri=' + @@redirectUri + 
    '&scope=https://www.googleapis.com/auth/calendar&response_type=code&approval_prompt=force&access_type=offline'
    
    redirect_to(url)
  end
  
  
  #google認証後のリダイレクト先URI
  def callback
    #引数(=コード)を取得して、DBを更新
    code = params[:code]
    if GoogleAccount.find_by(account_id: @@googleAccountId) != nil
      result = GoogleAccount.where(:account_id => @@googleAccountId).update_all(:code => code)
    end
    
    #　↓以下の処理をmodelのGoogleTokenクラスへ移動
    clientId = GoogleAccount.find_by(account_id: @@googleAccountId).client_id
    clientSecret = GoogleAccount.find_by(account_id: @@googleAccountId).client_secret
    redirectUri = GoogleAccount.find_by(account_id: @@googleAccountId).redirect_uri
    code = GoogleAccount.find_by(account_id: @@googleAccountId).code
    
    #クライアントID,クライアントシークレット,承認済みのリダイレクトURI,コードから、リフレッシュトークンとアクセストークンを取得
    postbody = {
      :client_id => clientId,
      :client_secret => clientSecret,
      :redirect_uri => redirectUri,
      :grant_type => "authorization_code",
      :code => code
    }
    
    #HTTP.post(URL)でURLにpostリクエストを送る
    res = HTTP.headers("Content-Type" => "application/x-www-form-urlencoded").post("https://accounts.google.com/o/oauth2/token", :form => postbody )
	  
  	if res.code.to_s == "200"
    	j = ActiveSupport::JSON.decode( res )
    	@@accessToken = j["access_token"]
    	@@refreshToken = j["refresh_token"]
    	@@expiresIn = Time.now + j["expires_in"].second   # expires_in => 3600秒(1時間)
    	  
    	#GoogleTokenテーブルに値を保存
      googleToken = GoogleToken.new(account_id: @@googleAccountId, access_token: @@accessToken, refresh_token:@@refreshToken, expire:@@expiresIn )
      googleToken.save
    else
      puts "Googleアクセストークンの取得に失敗しました。"
    end
    #　↑以上の処理をmodelのGoogleTokenクラスへ移動
  	  
  	createchannel
  	render action: 'createchannel'

  end
  
  
  #アクセストークンを利用してチャネルを作成
  def createchannel
    
    #　↓以下の処理をmodelのGoogleChannelクラスへ移動
    clientId = GoogleAccount.find_by(account_id: @@googleAccountId).client_id
    clientSecret = GoogleAccount.find_by(account_id: @@googleAccountId).client_secret
    refreshToken = GoogleToken.find_by(account_id: @@googleAccountId).refresh_token
    calendarId = GoogleAccount.find_by(account_id: @@googleAccountId).calendar_id
    
	  #GoogleApiを利用する
	  client = Google::APIClient.new
    client.authorization.client_id = clientId
    client.authorization.client_secret = clientSecret
    client.authorization.refresh_token = refreshToken
    client.authorization.fetch_access_token!
    
    service = client.discovered_api('calendar', 'v3')
    
    res = client.execute!(
      api_method: service.events.watch,
      parameters: { calendarId: calendarId },
      body_object: {
        id: SecureRandom.uuid(),
        type: 'web_hook',
        address: URI.encode(APP_CONFIG["webhost"]+'notifications/callback')
      }
    )
	  
	  @status = res.status
	  
	  if res.status.to_s == "200"
	    puts(res.body)
      @status = "認証に成功しました"
      
  	  j = ActiveSupport::JSON.decode( res.body )
  	  #resourceUri = j["resourceUri"]　#カレンダーIDが含まれているURIを取得."https://www.googleapis.com/calendar/v3/calendars/i8a77r26f9pu967g3pqpubv0ng@group.calendar.google.com/events?maxResults=250&alt=json"
	    
      #チャネルのIDと、カレンダーIDの対応を保存
      googleChannel = GoogleChannel.new(channel_id: j["id"], calendar_id: calendarId, access_token: "", refresh_token: refreshToken, expires_in: DateTime.now + 7.day, resource_id: j["resourceId"] )
      googleChannel.save
      debugger
    else
	  	@status = "認証に失敗しました"
	  end
	  #　↑以上の処理をmodelのGoogleChannelクラスへ移動
	  
  end
  
  
end
