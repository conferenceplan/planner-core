require 'datasource'
class CreateDatasources < ActiveRecord::Migration
 def self.up
      create_table :datasources do |t|
   
      t.string :name
      t.boolean :primary, {:default => false}
      t.timestamps
    end
    Datasource.create(:name => "Application")
  end

  def self.down
     drop_table :datasources
  end
end
