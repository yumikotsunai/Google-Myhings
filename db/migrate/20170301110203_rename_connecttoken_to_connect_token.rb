class RenameConnecttokenToConnectToken < ActiveRecord::Migration
  def change
    rename_table :connecttokens, :connect_tokens
  end
end
