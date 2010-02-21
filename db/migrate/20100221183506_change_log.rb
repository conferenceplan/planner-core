class ChangeLog < ActiveRecord::Migration
  def self.up
    create_table :changelog do |t|
      t.string :who
      t.timestamp :when
      t.string :description
      t.string :type
      t.string :old_value
    end
  end

  def self.down
    drop_table :changelog
  end
end
