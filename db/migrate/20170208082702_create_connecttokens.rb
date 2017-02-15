class CreateConnecttokens < ActiveRecord::Migration
  def change
    create_table :connecttokens do |t|
      t.string :key
      t.string :access_token
      t.string :refresh_token
      t.time :expire

      t.timestamps null: false
    end
  end
end

