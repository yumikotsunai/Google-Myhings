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
    
    #リフレッシュトークンとアクセストークンを取得してDB保存
    googleToken = GoogleToken.new
    googleToken.refresh
    
    #アクセストークンを利用してチャネルを作成
  	createchannel
  	render action: 'createchannel'

  end
  
  
  #アクセストークンを利用してチャネルを作成
  def createchannel
    #channel作成
    googleChannel = GoogleChannel.new
    @status = googleChannel.update
    debugger
    
  end
  
  
end
