class AddPeopleInvitationCategory < ActiveRecord::Migration
  def self.up
     add_column :people, :invitation_category_id, :integer
  end

  def self.down
    remove_column :people, :invitation_category_id
  end
end
