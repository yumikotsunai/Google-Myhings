include ConnectHttp
require 'net/https'
require 'http'
require 'time'
  
#ConnectのAOuth認証
class ConnecthookupController < ApplicationController
  
<<<<<<< HEAD
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
=======
  #connect認証のURLにリダイレクト
  def new
    key = "demo@remotelock.com"
    #ローカル環境
    @@client =	"248b4559af5bbdf84998f5c092bc8d9fac784712f28009168c0a1579818aef47"
    @@secret =	"b88822e0976b6e6a9fb0096a3b1c860b12f9a405fd2d0597a1d60cf68473ac46"
    @@callbackuri = URI.encode('https://google-demo-yumikotsunai.c9users.io/connecthookup/callback')
    
    #heroku環境
    #@@client =	"86169dfc79da7ce9000a1d2f37dcb95f96d9b3bb03bf32e57b540cbaedbf0989"
    #@@secret =	"1bfa525b96c3102c65d1f2be4abfa541f0b57ee17ac92dffbb9abf6417740c23"
    #@@callbackuri = URI.encode('https://kkeapidemo2.herokuapp.com/connecthookup/callback')
>>>>>>> my work リポにローカル環境用変数をセット
    
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
