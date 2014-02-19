class AddPubNameToPublishedAssignment < ActiveRecord::Migration
  def change
     add_column :published_programme_item_assignments, :person_name, :string
  end
end
