class GoogleChannels < ActiveRecord::Migration
  def change
    remove_column :google_channels, :access_token, :string
    remove_column :google_channels, :refresh_token, :string
  end
end
