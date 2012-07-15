class CreatePeoplesources < ActiveRecord::Migration
 def self.up
      create_table :peoplesources do |t|
   
      t.integer :person_id
      t.integer :datasource_id
      t.integer :datasource_dbid
      t.timestamps
      end
  end

  def self.down
      drop_table :peoplesources
  end
end
