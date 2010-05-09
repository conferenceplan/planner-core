class CreateMenus < ActiveRecord::Migration
  def self.up
    create_table :menus do |t|

      t.string :title, { :default => "" }

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :menus
  end
end
