class AddClientSecretToGoogleTokens < ActiveRecord::Migration
  def change
    add_column :google_tokens, :client_secret, :string
  end
end
