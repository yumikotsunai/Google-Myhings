class CreateConnectaccounts < ActiveRecord::Migration
  def change
    create_table :connectaccounts do |t|
      t.string :key
      t.string :client_id
      t.string :client_secret

      t.timestamps null: false
    end
  end
end

