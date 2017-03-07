class ConnectApiExec
    require 'http'
    include ConnectHttp
    
    def createperson
        puts "test"
    end
    
    def refreshtoken(account)
        #accountは更新するconnecttokensのレコード
        
        postform = {
            'client_id' => ConnectAccount.find_by(key: account.key).client_id ,
            'client_secret' => ConnectAccount.find_by(key: account.key).client_secret ,
            'refresh_token' => account.refresh_token,
            'grant_type' => 'refresh_token'     
        }
    end
    def post_connect(postform)
        res = HTTP.headers("Content-Type" => "application/x-www-form-urlencoded")
        .post("https://connect.lockstate.jp/oauth/token", :ssl_context => CTX , :form => postform)
        return res
    end
    
    def get_connect(uri)
        return
    end
end