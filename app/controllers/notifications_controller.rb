include ConnectHttp
require 'google/api_client'
require 'json'


class NotificationsController < ApplicationController
  
  # この↓一文がないとCSRF(Cross-Site Request Forgery)チェックでこけるので、APIをやりとりしているControllerには必要
  skip_before_filter :verify_authenticity_token
  
  @@count = 0
  @@email = ""
  @@startStr = ""
  @@endStr = ""
  
  
  #push notificationの受取り
  def callback
    
	  @@count = @@count + 1
	  puts(@@count) 
	  
    #googleCalendarからのrequest情報
    channelId = request.headers["HTTP_X_GOOG_CHANNEL_ID"]
    resourceId = request.headers["HTTP_X_GOOG_RESOURCE_ID"]
    
	  #不要なchannelの削除
	  #hookupクラスインスタンスの初期化
    #hookup = HookupController.new
    #accessToken = hookup.dispAccessToken
	  
    postbody = {
      "id": channelId,
      "resourceId": resourceId,
    }
    
    #auth = "Bearer " + accessToken
    #res = HTTP.headers("Content-Type" => "application/json",:Authorization => auth)
    #.post("https://www.googleapis.com/calendar/v3/channels/stop", :ssl_context => CTX , :body => postbody.to_json)
    
    #puts("channel削除")
    #puts(res.code)
    
    #イベント情報の取得
	  getevent
	  
  end
  
  
  #イベント情報の取得
  def getevent
    
    #hookupクラスインスタンスの初期化
    hookup = HookupController.new
    
    #クラス変数の値取得
    clientId = hookup.dispClientId
    clientSecret = hookup.dispClientSecret
    #redirectUri = hookup.dispRedirectUri
    calendarId = hookup.dispCalendarId
    #accessToken = hookup.dispAccessToken
    refreshToken = hookup.dispRefreshToken
    
    #GoogleApiイベントメソッド呼出し
    client = Google::APIClient.new
    client.authorization.client_id = clientId
    client.authorization.client_secret = clientSecret
    client.authorization.refresh_token = refreshToken
    client.authorization.fetch_access_token!
    
    service = client.discovered_api('calendar', 'v3')
    
    res = client.execute!(
      api_method: service.events.list,
      parameters: {
        calendarId: calendarId,
        updatedMin: 1.minute.ago.to_datetime.rfc3339
      }
    )
    
    res_hash = ActiveSupport::JSON.decode(res.body)
    items = res_hash["items"]
    puts("イベント情報の取得")
    puts(items)
    
    if !items.blank?
      email = ""
      addemail = ""
      startStr = ""
      endStr = ""
      
      items.each do |item|
        email = item["creator"]["email"]
        startStr = item["start"]["dateTime"]
        endStr = item["end"]["dateTime"]
        
        #debugger
        if startStr.blank?
          startStr = item["start"]["date"]
        end
        if endStr.blank?
          endStr = item["end"]["date"]
        end 
        
        #登録ユーザのアクセス権を取得
        callconnectapi(email, email, startStr, endStr)
        
        #追加メンバーのアクセス権を取得
        attendees = item["attendees"]
        if !attendees.blank?
          attendees.each do |attendee|
            debugger
            addemail = attendee["email"]
            callconnectapi(email, addemail, startStr, endStr)
          end
        end
      end
      
      @@email = email
      @@startStr = startStr
      @@endStr = endStr
      
    else
      puts("まだ")
	  end
    
  end
  
  
  #ConnectApiメソッド呼出し
  def callconnectapi(email, addemail, startStr, endStr)
    
    if @@email != email or @@startStr != startStr or @@endStr != endStr
      
      #ISO 8601時刻で日本時刻を世界時刻に変更（タイムゾーン+09:00を削除）
      #startDatetime = startStr.to_datetime - Rational(9, 24)  
      startAt = startStr.slice(0,19)
        
      #endDatetime = endStr.to_datetime - Rational(9, 24)  
      endAt = endStr.slice(0,19)
      
      #ConnectAPIの呼出し
      connectApi = ConnectapiController.new
        
      #アクセスゲストの作成
      connectApi.createguests(addemail,startAt,endAt)
    end 
  end
  
end
