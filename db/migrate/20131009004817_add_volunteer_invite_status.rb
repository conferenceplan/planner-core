require 'enum'
require 'invite_status'

class AddVolunteerInviteStatus < ActiveRecord::Migration
  def self.up
    InviteStatus.enumeration_model_updates_permitted = true
    InviteStatus.create(:name => 'Volunteered',:position => 6)
  end

  def self.down
  end
end
