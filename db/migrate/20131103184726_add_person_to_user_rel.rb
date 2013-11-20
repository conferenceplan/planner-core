class AddPersonToUserRel < ActiveRecord::Migration
  def change
    # Add an optional relationship betweem the user and a person within the database
    add_column :users, :person_id, :integer
  end
end
