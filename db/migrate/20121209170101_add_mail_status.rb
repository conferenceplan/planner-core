require 'enum'
require 'email_status'

class AddMailStatus < ActiveRecord::Migration
  def self.up
    add_column :survey_respondents, :email_status_id, :integer
    
    EmailStatus.enumeration_model_updates_permitted = true
    EmailStatus.create(:name => 'Pending', :position => 1)
    EmailStatus.create(:name => 'Sent', :position => 2)
    EmailStatus.create(:name => 'Failed', :position => 3)

  end

  def self.down
    remove_column :survey_respondents, :email_status_id
  end
end
