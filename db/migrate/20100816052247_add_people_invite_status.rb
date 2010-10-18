class AddPeopleInviteStatus < ActiveRecord::Migration
  def self.up
    add_column :people, :invitestatus_id, :integer
  end

  def self.down
     remove_column :people, :invitestatus_id
  end
end
