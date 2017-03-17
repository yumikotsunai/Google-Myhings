class PairsController < ApplicationController
    def decide
        #GoogleのアカウントIDをキーにしてGoogleAccountのDBを検索
        gAccount = GoogleAccount.find_by(:account_id => APP_CONFIG["google"]["user_name"] )
        
        #GoogleのアカウントIDをキーにしてGoogleAccountのDBを検索
        if CalendarToLock.find_by(calendar_id: gAccount.calendar_id) == nil
          #新規登録
          c2l = CalendarToLock.new(:calendar_id => gAccount.calendar_id ,:lock_id => params[:lockid])
          c2l.save
        else
          #更新する
          c2l = CalendarToLock.find_by(calendar_id: gAccount.calendar_id)
          CalendarToLock.update(c2l.id , :calendar_id => gAccount.calendar_id,:lock_id => params[:lockid])
        end
        
        redirect_to '/pairs/finish'
    end
    
    def finish
        render text:"初期設定が完了しました。GoogleCalendarから予定を登録してください。"
    end
end