class RemoveKeyToGoogleAccounts < ActiveRecord::Migration
  def change
    remove_column :google_accounts, :key, :string
  end
end
