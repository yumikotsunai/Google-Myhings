class CreateConnectAccesspeople < ActiveRecord::Migration
  def change
    create_table :connect_accesspeople do |t|

      t.timestamps null: false
    end
  end
end
