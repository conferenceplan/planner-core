class CreateChangeLogs < ActiveRecord::Migration
  def self.up
    create_table :change_logs do |t|
      t.string :who
      t.timestamp :when
      t.string :description
      t.string :type
      t.string :old_value

      t.timestamps
    end
  end

  def self.down
    drop_table :change_logs
  end
end
