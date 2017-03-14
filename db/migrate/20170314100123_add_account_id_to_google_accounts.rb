class AddAccountIdToGoogleAccounts < ActiveRecord::Migration
  def change
    add_column :google_accounts, :account_id, :string
  end
end
