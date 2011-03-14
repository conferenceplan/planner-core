class AddPurposeAndCommentToRooms < ActiveRecord::Migration
  def self.up
    add_column :rooms, :purpose, :string
    add_column :rooms, :comment, :string
  end

  def self.down
    remove_column :rooms, :comment
    remove_column :rooms, :purpose
  end
end
