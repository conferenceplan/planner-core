class CreateIndexesForFeed < ActiveRecord::Migration
  def self.up
    add_index :publications, [:published_id, :published_type], :name => 'pub_pub_id_type_index'
    add_index :publications, [:original_id, :original_type], :name => 'pub_original_id_type_index'
    add_index :published_programme_item_assignments, [:published_programme_item_id], :name => 'pub_progitem_assignment_item_index'
    add_index :published_programme_item_assignments, [:person_id], :name => 'pub_progitem_assignment_person_index'
    add_index :pseudonyms, [:person_id], :name => 'pseudonym_person_index'
    add_index :published_room_item_assignments, [:published_room_id], :name => 'pub_room_assign_room_index'
    add_index :published_room_item_assignments, [:published_programme_item_id], :name => 'pub_room_assign_item_index'
    add_index :published_room_item_assignments, [:published_time_slot_id], :name => 'pub_room_assign_time_index'
  end

  def self.down
    remove_index :publications, :name => 'pub_pub_id_type_index'
    remove_index :publications, :name => 'pub_original_id_type_index'
    remove_index :published_programme_item_assignments, :name => 'pub_progitem_assignment_item_index'
    remove_index :published_programme_item_assignments, :name => 'pub_progitem_assignment_person_index'
    remove_index :pseudonyms, :name => 'pseudonym_person_index'
    remove_index :published_room_item_assignments, :name => 'pub_room_assign_room_index'
    remove_index :published_room_item_assignments, :name => 'pub_room_assign_item_index'
    remove_index :published_room_item_assignments, :name => 'pub_room_assign_time_index'
  end
end
