class GoogleChannel < ActiveRecord::Base

    # チャネル更新（1週間以内に定期実行）
    def update_channel
        # ここに処理を記述
    end
end

# == Schema Information
#
# Table name: google_channels
#
#  channel_id       :string
#  calendar_id      :string
#  access_token     :string
#  refresh_token    :string
#  expires_in       :datetime
#  created_at       :datetime
#  updated_at       :datetime
