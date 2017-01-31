require 'http'

class HookupController < ApplicationController
  
  # この↓一文がないとCSRF(Cross-Site Request Forgery)チェックでこけるので、APIをやりとりしているControllerには必要
  skip_before_filter :verify_authenticity_token
  
  #クラス変数（同一クラス及びそこから生成されるオブジェクト（インスタンス）の中からどこからでも参照可能な変数）の初期化
  attr_accessor :clientId, :clientSecret, :redirectUri, :calendarId, :accessToken
  
  #クライアントID,クライアントシークレット,承認済みのリダイレクトURI,カレンダーIDを入力
  def setup
  end
  
  #上記変数を受取る
  def getcode
    @@clientId = params[:clientId]
    @@clientSecret = params[:clientSecret]
    @@redirectUri = params[:redirectUri]
    @@calendarId = params[:calendarId]
    
    #google認証のURLにリダイレクト
    url = 'https://accounts.google.com/o/oauth2/auth?client_id=' + @@clientId + '&redirect_uri=' + @@redirectUri + 
    '&scope=https://www.googleapis.com/auth/calendar&response_type=code&approval_prompt=force&access_type=offline'
    
    redirect_to(url)
  end
  
  
  #google認証後のリダイレクト先URI
  def callback
    #引数(=コード)を取得
    code = params[:code]
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
	  refreshToken = res_json["refresh_token"]
	  puts(@@accessToken)
	  puts(refreshToken)
	  
	  #インスタンスメソッド呼出し
	  hookup = HookupController.new
	  hookup.createchannel
	  
  end
  
  
  #アクセストークンを利用してチャネルを作成
  def createchannel
    
    #必要なのがhttpsなのでSSLを有効にする。とりあえず証明書は無視。
    ctx      = OpenSSL::SSL::SSLContext.new
    ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
    #HTTPにPOSTリクエストを送る
    postbody = {
      "id": SecureRandom.uuid(),
	    "type": "web_hook",
	    "address": "https://google-demo-yumikotsunai.c9users.io/hookup/createchannel"
    }
    puts(postbody)
    
    #HTTP.post(URL)でURLにpostリクエストを送る
    auth = "Bearer " + @@accessToken
    puts(auth)
    res = HTTP.headers("Content-Type" => "application/json",:Authorization => auth).post("https://www.googleapis.com/calendar/v3/calendars/yumikokke@gmail.com/events/watch", :ssl_context => ctx , :body => postbody.to_json)
	  puts(res)
  end
  
  
  
end
