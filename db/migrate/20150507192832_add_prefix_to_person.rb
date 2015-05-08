class AddPrefixToPerson < ActiveRecord::Migration
  def change
    add_column :people, :prefix, :string, {:default => ""}
  end
end
