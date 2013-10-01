class CreateUserInterfaceSettings < ActiveRecord::Migration
  def self.up
    create_table :user_interface_settings do |t|
      
      t.string :key,    :null => false
      t.string :_value,  :null => false # Serialized value

      t.timestamps
    end
  end
  
  def self.down
    drop_table :user_interface_settings
  end
end
