require 'enum'
require 'invite_status'

class AddEnum < ActiveRecord::Migration
  
  def self.up
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

  def self.down
    drop_table :enumrecord
  end
end
