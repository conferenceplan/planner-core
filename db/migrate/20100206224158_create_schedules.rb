class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :schedules
  end
end
