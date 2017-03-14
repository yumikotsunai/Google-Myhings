class AddStatusToGoogleTokens < ActiveRecord::Migration
  def change
    add_column :google_tokens, :status, :integer
  end
end
