require 'enum'
require 'invite_status'
require 'acceptance_status'

class RecreateEnumTable < ActiveRecord::Migration
  def self.up
       drop_table :enumrecord
       create_table :enumrecord do |t|
           t.string :type
           t.string :name
           t.integer :position
       end
       
       InviteStatus.enumeration_model_updates_permitted = true
       InviteStatus.create(:name => 'Not Set',:position => 1)
       InviteStatus.create(:name => 'Do Not Invite',:position => 2)
       InviteStatus.create(:name => 'Potential Invite', :position => 3)
       InviteStatus.create(:name => 'Invite Pending',:position => 4)
       InviteStatus.create(:name => 'Invited',:position => 5)
       
       AcceptanceStatus.enumeration_model_updates_permitted = true
       AcceptanceStatus.create(:name => 'Unknown', :position => 1)
       AcceptanceStatus.create(:name => 'Probable',:position => 2)
       AcceptanceStatus.create(:name => 'Accepted',:position => 3)
       AcceptanceStatus.create(:name => 'Declined',:position => 4)
  end

  def self.down
    drop_table :enumrecord
    
    create_table :enumrecord do |t|
          t.string :type
          t.string :name
          t.integer :position
    end
       
    InviteStatus.enumeration_model_updates_permitted = true
    InviteStatus.create(:name => 'Not Invited',:position => 1)
    InviteStatus.create(:name => 'Invited Pending',:position => 2)
    InviteStatus.create(:name => 'Invited',:position => 3)
    InviteStatus.create(:name => 'Accepted',:position => 4)
    InviteStatus.create(:name => 'Declined',:position => 5)
  end

end
