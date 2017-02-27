class CreateGoogleaccounts < ActiveRecord::Migration
  def change
    create_table :googleaccounts do |t|
      t.string :key
      t.string :client_id
      t.string :client_secret
      t.string :calendar_id

      t.timestamps null: false
      #drop_table :googleaccounts
    end
  end
end
