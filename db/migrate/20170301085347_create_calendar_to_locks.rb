class CreateCalendarToLocks < ActiveRecord::Migration
  def change
    create_table :calendar_to_locks do |t|
      t.string :calendar_id
      t.string :lock_id

      t.timestamps null: false
    end
  end
end
