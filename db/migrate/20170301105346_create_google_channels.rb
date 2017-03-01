class CreateGoogleChannels < ActiveRecord::Migration
  def change
    create_table :google_channels do |t|
      t.string :channel_id
      t.string :calendar_id
      t.string :access_token
      t.string :refresh_token
      t.datetime :expires_in

      t.timestamps null: false
    end
  end
end
