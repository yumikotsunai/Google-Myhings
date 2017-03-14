class RemoveKeyToGoogleTokens < ActiveRecord::Migration
  def change
    remove_column :google_tokens, :key, :string
  end
end
