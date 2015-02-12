class FixProgramNoteField < ActiveRecord::Migration
  def up
    rename_column :programme_items, :notes, :item_notes    
  end

  def down
    rename_column :programme_items, :item_notes, :notes    
  end
end
