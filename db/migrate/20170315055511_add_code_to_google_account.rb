class AddCodeToGoogleAccount < ActiveRecord::Migration
  def change
    add_column :google_accounts, :code, :string
  end
end
