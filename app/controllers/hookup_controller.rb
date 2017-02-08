require 'http'
require 'google/api_client'

class HookupController < ApplicationController
  
  # この↓一文がないとCSRF(Cross-Site Request Forgery)チェックでこけるので、APIをやりとりしているControllerには必要
  skip_before_filter :verify_authenticity_token
  
  #クラス変数（同一クラス及びそこから生成されるオブジェクト（インスタンス）の中からどこからでも参照可能な変数）の初期化
  #attr_reader :clientId, :clientSecret, :redirectUri, :calendarId, :accessToken, :refreshToken
  
  #クライアントID,クライアントシークレット,承認済みのリダイレクトURI,カレンダーIDを入力
  def setup
  end
  
  #上記変数を受取る
  def getcode
    @@clientId = params[:clientId]
    @@clientSecret = params[:clientSecret]
    @@calendarId = params[:calendarId]
    @@redirectUri = "https://google-demo-yumikotsunai.c9users.io/hookup/callback"
    
    #google認証のURLにリダイレクト
    url = 'https://accounts.google.com/o/oauth2/auth?client_id=' + @@clientId + '&redirect_uri=' + @@redirectUri + 
    '&scope=https://www.googleapis.com/auth/calendar&response_type=code&approval_prompt=force&access_type=offline'
    
    redirect_to(url)
  end
  
  
  #google認証後のリダイレクト先URI
  def callback
    #引数(=コード)を取得
    code = params[:code]
    puts("インスタンス変数")
    puts(@@clientId)
    puts(@@clientSecret)
    puts(@@redirectUri)
    
    #クライアントID,クライアントシークレット,承認済みのリダイレクトURI,コードから、リフレッシュトークンとアクセストークンを取得
    postbody = {
      :client_id => @@clientId,
      :client_secret => @@clientSecret,
      :redirect_uri => @@redirectUri,
      :grant_type => "authorization_code",
      :code => code
    }
    
    #HTTP.post(URL)でURLにpostリクエストを送る
    res = HTTP.headers("Content-Type" => "application/x-www-form-urlencoded").post("https://accounts.google.com/o/oauth2/token", :form => postbody )
	  puts(res)
	  
	  res_json = JSON.parse res
	  puts(res_json)
	  @@accessToken = res_json["access_token"]
	  @@refreshToken = res_json["refresh_token"]
	  #puts(@@accessToken)
	  #puts(@@refreshToken)
	  
	  #インスタンスメソッド呼出し
	  #hookup = HookupController.new
	  #hookup.createchannel
	  createchannel
	 
	  #render :nothing => true
	  render action: 'createchannel'
	  
  end
  
  
  #アクセストークンを利用してチャネルを作成
  def createchannel
    
    #(方法1)HTTPにPOSTリクエストを送る⇒こちらはCh
    #必要なのがhttpsなのでSSLを有効にする。とりあえず証明書は無視。
    #ctx      = OpenSSL::SSL::SSLContext.new
    #ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
    #HTTPにPOSTリクエストを送る
    #postbody = {
    #  "id": SecureRandom.uuid(),
	  #  "type": "web_hook",
	  #  "address": "https://google-demo-yumikotsunai.c9users.io/notifications/callback"
    #}
    #puts(postbody)
    
    ##HTTP.post(URL)でURLにpostリクエストを送る
    #auth = "Bearer " + @@accessToken
    #res = HTTP.headers("Content-Type" => "application/json",:Authorization => auth).post("https://www.googleapis.com/calendar/v3/calendars/yumikokke@gmail.com/events/watch", :ssl_context => ctx , :body => postbody.to_json)
	  
	  #(方法2)GoogleApiを利用する
	  client = Google::APIClient.new

    client.authorization.client_id = @@clientId
    client.authorization.client_secret = @@clientSecret
    client.authorization.refresh_token = @@refreshToken
    client.authorization.fetch_access_token!
    
    service = client.discovered_api('calendar', 'v3')
    
    res = client.execute!(
      api_method: service.events.watch,
      parameters: { calendarId: @@calendarId },
      body_object: {
        id: SecureRandom.uuid(),
        type: 'web_hook',
        address: 'https://google-demo-yumikotsunai.c9users.io/notifications/callback'
      }
    )
	  
	  @status = res.status
	  
	  #if res.status == "200"
    #  @status = "システムの連携に成功しました"
    #else
	  #	@status = "システムの連携に失敗しました"
	  #end
	   
	  #puts(@status)
	  #puts(res.body)
	  
  end
  
  
  #クラス変数用メソッド
  def dispClientId
    return @@clientId
  end
  
  def dispClientSecret
    return @@clientSecret
  end
  
  def dispRedirectUri
    return @@redirectUri
  end
  
  def dispCalendarId
    return @@calendarId
  end
  
  def dispAccessToken
    return @@accessToken
  end
  
  def dispRefreshToken
    return @@refreshToken
  end
  
  
  
end
