class AddTagIndex < ActiveRecord::Migration
  def up
    add_index :taggings, :taggable_id
  end

  def down
    remove_index :taggings, :taggable_id
  end
end
