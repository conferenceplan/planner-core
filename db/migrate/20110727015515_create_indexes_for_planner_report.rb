class CreateIndexesForPlannerReport < ActiveRecord::Migration
  def self.up
    add_index :addresses, [:addressable_id], :name => 'addr_id_index'
    add_index :addresses, [:addressable_type], :name => 'addr_type_index'
    add_index :addresses, [:person_id], :name => 'addr_person_id_index'
  end

  def self.down
    remove_index :addresses, :name => 'addr_id_index'
    remove_index :addresses, :name => 'addr_type_index'
    remove_index :addresses, :name => 'addr_person_id_index'
  end
end
