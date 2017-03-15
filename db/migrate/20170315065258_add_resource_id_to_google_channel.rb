class AddResourceIdToGoogleChannel < ActiveRecord::Migration
  def change
    add_column :google_channels, :resource_id, :string
  end
end
