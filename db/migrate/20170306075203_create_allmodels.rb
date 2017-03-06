class CreateAllmodels < ActiveRecord::Migration
  def change
    create_table :calendar_to_locks do |t|
      t.string :calendar_id
      t.string :lock_id

      t.timestamps null: false
    end
    create_table :connect_accounts do |t|
      t.string :key
      t.string :client_id
      t.string :client_secret

      t.timestamps null: false
    end
    create_table :connect_locks do |t|
      t.string :uuid
      t.string :account_id

      t.timestamps null: false
    end
    create_table :connect_tokens do |t|
      t.string :key
      t.string :access_token
      t.string :refresh_token
      t.datetime :expire

      t.timestamps null: false
    end
    create_table :google_accounts do |t|
      t.string :key
      t.string :client_id
      t.string :client_secret
      t.string :calendar_id

      t.timestamps null: false
      #drop_table :googleaccounts
    end
    create_table :google_calendars do |t|
      t.string :calendar_id
      t.string :account_id

      t.timestamps null: false
    end
    create_table :google_channels do |t|
      t.string :channel_id
      t.string :calendar_id
      t.string :access_token
      t.string :refresh_token
      t.datetime :expires_in

      t.timestamps null: false
    end
    create_table :google_tokens do |t|
      t.string :key
      t.string :account_id
      t.string :access_token
      t.string :refresh_token
      t.datetime :expire

      t.timestamps null: false
    end
  end
end
