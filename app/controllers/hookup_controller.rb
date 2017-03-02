require 'http'
require 'google/api_client'

#GoogleCalendarのAOuth認証
class HookupController < ApplicationController
  
  # この↓一文がないとCSRF(Cross-Site Request Forgery)チェックでこけるので、APIをやりとりしているControllerには必要
  skip_before_filter :verify_authenticity_token
  
  #クライアントID,クライアントシークレット,承認済みのリダイレクトURI,カレンダーIDを入力
  def setup
  end
  
  #上記変数を受取る
  def getcode
<<<<<<< HEAD
    @@clientId = params[:clientId]
    @@clientSecret = params[:clientSecret]
    @@calendarId = params[:calendarId]
    @@redirectUri = params[:redirectUri]
    
    #以下だと、入力文字列が認識されないようなのでコメントアウト
    #@@clientId = APP_CONFIG["google"]["client"] || params[:clientId].presence
    #@@clientSecret = APP_CONFIG["google"]["secret"] || params[:clientSecret]
    #@@calendarId = APP_CONFIG["google"]["calendar_id"] || params[:calendarId]
    #@@redirectUri = APP_CONFIG["webhost"]+'hookup/callback' || params[:redirectUri]
=======
    #@@clientId = params[:clientId]
    @@clientId = "841258018012-jqn06q4ifmfvbj5ip42rvtemetcga7oj.apps.googleusercontent.com"
    #@@clientId = "404180661728-qotv9so92qt4pp6s7v9jlmheik6bespe.apps.googleusercontent.com"
    #@@clientSecret = params[:clientSecret]
    @@clientSecret = "HuQ43i5_NiqOeOIZca4oJttJ"
    #@@clientSecret = "_ZS6_pVing3DInTzpJ7c3QpJ"
    #@@calendarId = params[:calendarId]
    @@calendarId = "i8a77r26f9pu967g3pqpubv0ng@group.calendar.google.com"
    #@@calendarId = "g8ukpibvlfle41hplt1g3rplu0@group.calendar.google.com"
    #@@redirectUri = params[:redirectUri]
    @@redirectUri = "https://google-demo-yumikotsunai.c9users.io/hookup/callback"
    #@@redirectUri = "https://kkeapidemo2.herokuapp.com/hookup/callback"
>>>>>>> my work リポにローカル環境用変数をセット
    
    #google認証のURLにリダイレクト
    url = 'https://accounts.google.com/o/oauth2/auth?client_id=' + @@clientId + '&redirect_uri=' + @@redirectUri + 
    '&scope=https://www.googleapis.com/auth/calendar&response_type=code&approval_prompt=force&access_type=offline'
    
    redirect_to(url)
  end
  
  
  #google認証後のリダイレクト先URI
  def callback
    #引数(=コード)を取得
    code = params[:code]
    #puts(@@clientId)
    #puts(@@clientSecret)
    #puts(@@redirectUri)
    
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
	  #puts(res)
	  
	  res_json = JSON.parse res
	  #puts(res_json)
	  @@accessToken = res_json["access_token"]
	  @@refreshToken = res_json["refresh_token"]
	  #puts(@@accessToken)
	  #puts(@@refreshToken)
	  
	  createchannel
	  
	  render action: 'createchannel'
	  
  end
  
  
  #アクセストークンを利用してチャネルを作成
  def createchannel
    
	  #GoogleApiを利用する
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
<<<<<<< HEAD
        address: URI.encode(APP_CONFIG["webhost"]+'notifications/callback')
=======
        #ローカル環境
        address: 'https://google-demo-yumikotsunai.c9users.io/notifications/callback'
        #heroku環境
        #address: 'https://kkeapidemo2.herokuapp.com/notifications/callback'
>>>>>>> my work リポにローカル環境用変数をセット
      }
    )
    
	  
	  @status = res.status
	  
	  if res.status.to_s == "200"
      @status = "認証に成功しました"
    else
	  	@status = "認証に失敗しました"
	  end
	  
	  puts(res.body)
	  
	  #カレンダーIDが含まれているURIを取得.以下は取得例
	  #"https://www.googleapis.com/calendar/v3/calendars/i8a77r26f9pu967g3pqpubv0ng@group.calendar.google.com/events?maxResults=250&alt=json"
	  j = ActiveSupport::JSON.decode( res.body )
	  resourceUri = j["resourceUri"]
   
	  
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
