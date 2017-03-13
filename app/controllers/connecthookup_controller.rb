include ConnectHttp
require 'net/https'
require 'http'
require 'time'
  
#ConnectのAOuth認証
class ConnecthookupController < ApplicationController
  
  def setup
    #認証情報の入力画面
    session[:_id]
  end
    
  def getcode
    key = 	APP_CONFIG["connect"]["user_name"]
    @@client =	params[:clientId].presence || APP_CONFIG["connect"]["client"]
    @@secret =	params[:clientSecret].presence || APP_CONFIG["connect"]["secret"]
    @@callbackuri = URI.encode(APP_CONFIG["webhost"]+'connecthookup/callback')
    #params[:uuId]
    
    if ConnectAccount.find_by(key: key) == nil
      account = ConnectAccount.new(key: key,client_id: @@client,client_secret: @@secret)
      account.save
    end
    
    req = 'https://connect.lockstate.jp/oauth/'+'authorize?'+'client_id='+@@client+'&response_type=code&redirect_uri='+@@callbackuri
    redirect_to req
  end

  #トークンの受取り
  def callback
    #必要なのがhttpsなのでSSLを有効にする。とりあえず証明書は無視。
    #ctx = OpenSSL::SSL::SSLContext.new
    #ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    tmp_token = params[:code]
    postform = {'code' => tmp_token \
    ,'client_id' => @@client \
    ,'client_secret' => @@secret \
    ,'redirect_uri' => @@callbackuri\
    ,'grant_type' => 'authorization_code' }
    
    res = HTTP.headers("Content-Type" => "application/x-www-form-urlencoded")
    .post("https://connect.lockstate.jp/oauth/token", :ssl_context => CTX , :form => postform)
    
    if res.code!=200
      @res = res
      @state = "認証に失敗しました"
      render
    else
      @res = res
      j = ActiveSupport::JSON.decode( @res.body )
      require 'time'
      #require 'date'
      #Time.now.strftime("%Y年 %m月 %d日, %H:%M:%S")
      key =	APP_CONFIG["connect"]["user_name"]
      data = { \
        :key => key \
        ,:access_token => j["access_token"] \
        ,:refresh_token => j["refresh_token"] \
        ,:expire => Time.at(j["created_at"])+j["expires_in"].second \
        ,:status => 1
      }
      #begin
      
      if ConnectToken.find_by(key: key) == nil
        connecttoken = ConnectToken.new(data)
        connecttoken.save
        puts "新しいものとして認識"
      else
        connecttoken = ConnectToken.find_by(:key => key)
        ConnectToken.update(connecttoken.id , :key => key,:access_token => j["access_token"] ,:refresh_token => j["refresh_token"] ,:expire => j["created_at"]+j["expires_in"],:updated_at => Time.now)
        puts "更新する"
      end
      #rescue
      #  puts "データベースへの保存で問題が発生しました"
      #end
      session[:session_id]
      @res = connecttoken
      @state = "認証に成功しました"
      render
    end
  end
  
  def selectlock
  end
  
  def deflock
   
  end
  
end
