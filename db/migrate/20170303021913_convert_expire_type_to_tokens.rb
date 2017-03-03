class ConvertExpireTypeToTokens < ActiveRecord::Migration
  def up
    change_table :connect_tokens do |t|
      t.change :expire, :datetime
    end
  end

  def down
    change_table :connect_tokens do |t|
      t.change :expire, :time
    end
  end
end
