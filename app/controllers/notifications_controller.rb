require 'google/api_client'


class NotificationsController < ApplicationController
  
  # この↓一文がないとCSRF(Cross-Site Request Forgery)チェックでこけるので、APIをやりとりしているControllerには必要
  skip_before_filter :verify_authenticity_token
  
  #push notificationの受取り
  def callback
    
    #読み込み時に一度パースが必要
	  #json_request = JSON.parse(request.body.read)
	  
	  #puts(response.headers)
	  #puts(response.body)
    
    #if request.body.read.blank?
    #  puts(request.body.)
    #else
	  #	puts("空")
	  #end
	  
	  #push notificationを受取ったらイベント情報を取得
	  getevent
	  
  end
  
  
  #イベント情報の取得
  def getevent
    
    #hookupクラスインスタンスの初期化
    hookup = HookupController.new
    
    #クラス変数の値取得
    clientId = hookup.dispClientId
    clientSecret = hookup.dispClientSecret
    redirectUri = hookup.dispRedirectUri
    calendarId = hookup.dispCalendarId
    accessToken = hookup.dispAccessToken
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
    
    puts("イベント情報の取得")
    #puts(res.headers)
    puts(res.body)
    
    res_hash = JSON.parse(res.body)
    puts(res_hash)
    
    #イベント詳細
    item = res_hash["items"]
    
    
    if !item.blank?
      puts("データ")
      puts(item)
      #creator = res_hash["items"]["creator"]
      #puts(creator)
      
      creator = "yumikokke@gmail.com"
      startAt = "2017-02-15T08:00:00+09:00"
      endAt = "2017-02-15T09:00:00+09:00"
      
      
      
    else
      puts("まだ")
	  end
    
    
    #item2 = JSON.parse(params[:items])
    #puts(item2)
    
    #if !params[:items].blank?
    #  item2 = JSON.parse(params[:items])
    #  puts("データ")
    #  puts(item2)
    #else
	  #	puts("まだ")
	  #end
    
	  #creator = item["creator"]
	  #email = creator["email"]
	  #startAt = item["start"]
	  #startTime = startAt["dateTime"]
	  #endAt = item["end"]
	  #endTime = endAt["dateTime"]
	  
  end
  
end
