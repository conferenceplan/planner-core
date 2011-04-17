class CreateAvailableDates < ActiveRecord::Migration
  def self.up
      create_table :available_dates do |t|
      
       t.datetime :start_time
       t.datetime :end_time
       t.references :person
       t.timestamps
       t.column :lock_version, :integer, { :default => 0 }
   end
  end

  def self.down
    drop_table  :available_dates
  end

end
