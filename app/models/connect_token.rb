class ConnectToken < ActiveRecord::Base
    
    # アクセストークンのリフレッシュ（2時間以内に定期実行）
    def refresh
        # ここに処理を記述
        #accountは更新するconnecttokensのレコード
        
        postform = {
            'client_id' => ConnectAccount.find_by(key: self.key).client_id ,
            'client_secret' => ConnectAccount.find_by(key: self.key).client_secret ,
            'refresh_token' => self.refresh_token,
            'grant_type' => 'refresh_token'     
        }
        
        res = HTTP.headers("Content-Type" => "application/x-www-form-urlencoded")
        .post("https://connect.lockstate.jp/oauth/token", :ssl_context => CTX , :form => postform)
        
        if res.code == 200
            puts "Connectアクセストークンの更新に成功しました。"
            j = ActiveSupport::JSON.decode( res.body )
            self.access_token = j["access_token"]
            self.refresh_token = j["refresh_token"]
            self.expire = Time.at(j["created_at"])+j["expires_in"].second
            self.status = 1
            self.save
        else
            self.status = 0
            puts "Connectアクセストークンの更新に失敗しました。"
            puts self
            puts res
        end
        return
    end
end

# == Schema Information
#
# Table name: connect_tokens
#
#  key              :string
#  access_token     :string
#  refresh_token    :string
#  expire           :datetime
#  created_at       :datetime
#  updated_at       :datetime
