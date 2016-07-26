class AddLinkedInToBio < ActiveRecord::Migration
  def change
    add_column :edited_bios, :linkedin, :text, {:default => nil}
  end
end
