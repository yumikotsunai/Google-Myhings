class CreateGoogleTokens < ActiveRecord::Migration
  def change
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
