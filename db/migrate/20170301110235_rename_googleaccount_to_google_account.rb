class RenameGoogleaccountToGoogleAccount < ActiveRecord::Migration
  def change
    rename_table :googleaccounts, :google_accounts
  end
end
