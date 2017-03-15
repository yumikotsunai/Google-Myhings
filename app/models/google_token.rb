class GoogleToken < ActiveRecord::Base
    def new
    
    end
    
    # アクセストークンのリフレッシュ（2時間以内に定期実行）
    def refresh
        # ここに処理を記述
        
        #クライアントID,クライアントシークレット,承認済みのリダイレクトURI,コードから、リフレッシュトークンとアクセストークンを取得
        googleAccountId = APP_CONFIG["google"]["user_name"]
        clientId = GoogleAccount.find_by(account_id: googleAccountId).client_id
        clientSecret = GoogleAccount.find_by(account_id: googleAccountId).client_secret
        redirectUri = GoogleAccount.find_by(account_id: googleAccountId).redirect_uri
        code = GoogleAccount.find_by(account_id: googleAccountId).code
        
        postbody = {
          :client_id => clientId,
          :client_secret => clientSecret,
          :redirect_uri => redirectUri,
          :grant_type => "authorization_code",
          :code => code
        }
        
        #HTTP.post(URL)でURLにpostリクエストを送る
        res = HTTP.headers("Content-Type" => "application/x-www-form-urlencoded").post("https://accounts.google.com/o/oauth2/token", :form => postbody )
    	  
      	if res.code.to_s == "200"
        	j = ActiveSupport::JSON.decode( res )
        	self.account_id = APP_CONFIG["google"]["user_name"]
        	self.access_token = j["access_token"]
        	self.refresh_token = j["refresh_token"]
        	self.expire = Time.now + j["expires_in"].second   # expires_in => 3600秒(1時間)
        	self.status = 1
        	self.save
        else
            self.status = 0
            puts "Googleアクセストークンの更新に失敗しました。"
            puts self
            puts res
        end
        debugger
    end
    
    
    def delete
        
    end
end

# == Schema Information
#
# Table name: google_tokens
#
#  key              :string
#  account_id       :string
#  access_token     :string
#  refresh_token    :string
#  expire           :datetime
#  created_at       :datetime
#  updated_at       :datetime
