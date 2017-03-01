class CreateGoogleCalendars < ActiveRecord::Migration
  def change
    create_table :google_calendars do |t|
      t.string :calendar_id
      t.string :account_id

      t.timestamps null: false
    end
  end
end
