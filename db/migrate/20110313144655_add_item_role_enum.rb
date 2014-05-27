require 'enum'
require 'person_item_role'

class AddItemRoleEnum < ActiveRecord::Migration
  def self.up
       PersonItemRole.enumeration_model_updates_permitted = true
       PersonItemRole.create(:name => 'Participant',:position => 1)
       PersonItemRole.create(:name => 'Moderator',:position => 2)
       PersonItemRole.create(:name => 'Speaker',:position => 3)
       PersonItemRole.create(:name => 'Reserved',:position => 4)
  end

  def self.down
  end
end
