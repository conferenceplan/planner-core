class ChangeRoomsCommentTypeToText < ActiveRecord::Migration
  def up
    change_column :rooms, :comment, :text, :limit => 16777215
  end

  def down
  end
end
