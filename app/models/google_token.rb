class GoogleToken < ActiveRecord::Base
    def new
    
    end
    
    # アクセストークンのリフレッシュ（2時間以内に定期実行）
    def refresh
        # ここに処理を記述
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
