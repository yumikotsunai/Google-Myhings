class AddRedirectUriToGoogleAccounts < ActiveRecord::Migration
  def change
    add_column :google_accounts, :redirect_uri, :string
  end
end
