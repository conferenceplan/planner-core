class RenameRoomNameColumn < ActiveRecord::Migration
   def self.up
    rename_column :rooms,:string, :name
  end

  def self.down
    rename_column :rooms,:name, :string
  end
end
