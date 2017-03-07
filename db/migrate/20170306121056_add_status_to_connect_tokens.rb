class AddStatusToConnectTokens < ActiveRecord::Migration
  def change
    add_column :connect_tokens, :status, :integer
  end
end
