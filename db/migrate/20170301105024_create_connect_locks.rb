class CreateConnectLocks < ActiveRecord::Migration
  def change
    create_table :connect_locks do |t|
      t.string :uuid
      t.string :account_id

      t.timestamps null: false
    end
  end
end
