class RemoveResourceIdToGoogleChannel < ActiveRecord::Migration
  def change
    remove_column :google_channels, :resourceId, :string
  end
end
