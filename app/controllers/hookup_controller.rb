require 'http'
require 'base64'

class HookupController < ApplicationController
  
  # この↓一文がないとCSRFチェックでこけるので、APIをやりとりしているControllerには必要
  skip_before_filter :verify_authenticity_token
  
  #クラス変数（同一クラス及びそこから生成されるオブジェクト（インスタンス）の中からどこからでも参照可能な変数）の初期化
  attr_accessor :clientId, :clientSecret, :redirectUri, :calendarId 
  
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
    
    encoded_code = Base64.encode64(code)
    puts(encoded_code)
    puts(@@clientId)
    puts(@@clientSecret)
    puts(@@redirectUri)
    
    #クライアントID,クライアントシークレット,承認済みのリダイレクトURI,コードから、リフレッシュトークンとアクセストークンを取得
    
    #command = 'curl -d client_id=' + @@clientId + '-d client_secret=' + @@clientSecret + '-d redirect_uri=' + 
    #@@redirectUri + '-d grant_type=authorization_code -d code=' + code + 'https://accounts.google.com/o/oauth2/token'
    
    #puts(command)
    
    #必要なのがhttpsなのでSSLを有効にする。とりあえず証明書は無視。
    ctx      = OpenSSL::SSL::SSLContext.new
    ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
    #HTTPにPOSTリクエストを送る（方法1）
    postbody = {
      "client_id" => @@clientId,
      "client_secret" => @@clientSecret,
      "redirect_uri" => @@redirectUri,
      "grant_type" => "authorization_code",
    }
    
          #"code" => encoded_code,
    
    puts('ボディ')
    puts(postbody)
    
    #req = "https://accounts.google.com/o/oauth2/token?grant_type=authorization_code&client_id=" + @@clientId + "&client_secret=" + @@clientSecret + "&redirect_uri=" + @@redirectUri + "&code=" + code
    #puts(req)
    
    #ヘッダーに認証用の情報をつけておく
    #HTTP.post(URL)でURLにpostリクエストを送る（送ってresにレスポンスを取得。）
    auth = "Basic " + encoded_code
    puts(auth)
    res = HTTP.headers("Content-Type" => "application/x-www-form-urlencoded",:Authorization => auth).post("https://accounts.google.com/o/oauth2/token", :ssl_context => ctx , :body => postbody)
    #res = HTTP.get(req, :ssl_context => ctx)

	  puts(res)
	  
	  
	  
	  
	  
	  
    
  end
  
  def createchannel
  end
end
