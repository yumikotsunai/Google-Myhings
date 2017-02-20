require 'http'
require 'json'
include ConnectHttp
#module ConnectHttpで共通化。CTX:SSL証明

#ConnectAPIの呼出し
class ConnectapiController < ApplicationController
  
  # この↓一文がないとCSRF(Cross-Site Request Forgery)チェックでこけるので、APIをやりとりしているControllerには必要
  skip_before_filter :verify_authenticity_token
    
  #リフレッシュ
  def refresh
    key = "demo@remotelock.com"
    account = Connecttoken.find_by(key: key)
    puts account
    puts account.updated_at
    o1 = account.updated_at.to_s
    o2 = account.access_token
    apieexec = ConnectApiExec.new
    apieexec.refreshtoken(account)
    txt = "更新日"+ account.updated_at.to_s + "　キー:" + account.access_token + "<br>" + "旧更新：" + o1 +"　旧キー"+ o2
    render :text => txt
  end
  
  
  #アクセスゲスト作成
  def createguests(email="名無し", statAt="2017-01-24T16:04:00", endAt="2017-01-25T16:04:00")
    #ctx = OpenSSL::SSL::SSLContext.new
    #ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    #PINコード番号のランダム生成
    pin = (0..9).sort_by{rand}[0,6].join.to_s
   
    #emailからname生成
    #name = email
    #name = name.slice!(email.index("@"), email.length - email.index("@") + 1)
   
    postbody = {
      "type": "access_guest",
      "attributes": {
        "name": email,
        "pin": pin,
        "starts_at": statAt,
        "ends_at": endAt,
        "email": email
      }
    }
    #puts(postbody)
    
    authtoken = "Bearer "+ Connecttoken.find_by(key: "demo@remotelock.com").access_token
    res = HTTP.headers("Content-Type" => "application/json",:Authorization => authtoken )
    .post("https://api.lockstate.jp/access_persons", :ssl_context => CTX , :body => postbody.to_json)
    
    puts("アクセスゲスト作成")
    puts(res.body)
    
    res_hash = ActiveSupport::JSON.decode(res.body)
    data = res_hash["data"]
    user_id = data["id"]
    
    #ロックと紐付け
    appendguest2lock(user_id)
    
    #メール送信
    sendemail(user_id)
    
    #if res.headers['code'] != '200' then
    #  puts("失敗")
    #  puts res.body
    #  puts res.headers
    #  puts res.headers['HTTP_STATUS_CODES']
    #else
    #  puts("成功")
    #  @res = ActiveSupport::JSON.decode(res.body)
    #  puts(@res["data"])
    #  render
    #end
    
    #puts @res
    
  end
  
  
  #アクセスゲストにロック権限を追加
  def appendguest2lock(access_persons_id = "0905462f-1a3c-45fd-a330-85c0865d5ef5")
    
    #ctx = OpenSSL::SSL::SSLContext.new
    #ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    postbody = {
      "attributes": {
        "accessible_id": "a890e645-efa3-4f01-a234-97777c355313",
        "accessible_type": "lock",
      }
    }
    
    authtoken = "Bearer "+ Connecttoken.find_by(key: "demo@remotelock.com").access_token
    apiUri = "https://api.lockstate.jp/access_persons/" + access_persons_id + "/accesses"
    
    res = HTTP.headers("Content-Type" => "application/json",:Authorization => authtoken)
    .post(apiUri, :ssl_context => CTX , :body => postbody.to_json)
    
    puts("ロック権限追加")
    puts res
    
  end
  
  
  #アクセスゲストにメールを送信
  def sendemail(access_persons_id = "0905462f-1a3c-45fd-a330-85c0865d5ef5")
    
    #ctx      = OpenSSL::SSL::SSLContext.new
    #ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    authtoken = "Bearer "+ Connecttoken.find_by(key: "demo@remotelock.com").access_token
    apiuri = "https://api.lockstate.jp/access_persons/" + access_persons_id + "/email/notify"
    
    res = HTTP.headers("Content-Type" => "application/json",:Authorization => authtoken )
    .post(apiuri, :ssl_context => CTX)
    
    puts("メール送信")
    puts(res)
    
  end
  
  
  #ロック一覧を取得
  def getlocks
    #ctx      = OpenSSL::SSL::SSLContext.new
    #ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    authtoken = "Bearer "+ Connecttoken.find_by(key: "demo@remotelock.com").access_token
    
    res = HTTP.headers(:accept => "vnd.lockstate.v1+json",:Authorization => authtoken)
    .get("https://api.lockstate.jp/devices?type=lock", :ssl_context => CTX)
    
    @res = ActiveSupport::JSON.decode(res.body)
    puts @res
    
    render
  end
  
  
end
