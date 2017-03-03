class RenameConnectaccountToConnectAccount < ActiveRecord::Migration
  def change
    rename_table :connectaccounts, :connect_accounts
  end
end
