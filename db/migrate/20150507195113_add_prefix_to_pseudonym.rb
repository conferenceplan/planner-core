class AddPrefixToPseudonym < ActiveRecord::Migration
  def change
    add_column :pseudonyms, :prefix, :string, {:default => ""}
  end
end
