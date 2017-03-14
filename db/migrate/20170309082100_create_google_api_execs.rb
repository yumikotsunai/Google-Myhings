class CreateGoogleApiExecs < ActiveRecord::Migration
  def change
    create_table :google_api_execs do |t|

      t.timestamps null: false
    end
  end
end
