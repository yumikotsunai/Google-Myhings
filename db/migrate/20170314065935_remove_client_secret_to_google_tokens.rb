class RemoveClientSecretToGoogleTokens < ActiveRecord::Migration
  def change
    remove_column :google_tokens, :client_secret, :string
  end
end
