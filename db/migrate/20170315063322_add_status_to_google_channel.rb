class AddStatusToGoogleChannel < ActiveRecord::Migration
  def change
    add_column :google_channels, :status, :integer
  end
end
