class PairsController < ApplicationController
    def decide
        g = GoogleAccount.find_by(:key => APP_CONFIG["google"]["user_name"] )
        #カレンダaccount_id
        c2l = CalendarToLock.new(:calendar_id => g.calendar_id ,:lock_id => params[:lockid])
        c2l.save
        redirect_to '/pairs/finish'
    end
    
    def finish
        render text:"初期設定が完了しました。GoogleCalendarから予定を登録してください。"
    end
end