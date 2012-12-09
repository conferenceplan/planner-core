class CreateMailUseEnum < ActiveRecord::Migration
  def self.up
       MailUse.enumeration_model_updates_permitted = true
       MailUse.create(:name => 'Invite', :position => 1)
       MailUse.create(:name => 'Schedule',:position => 2)
       MailUse.create(:name => 'CompletedSurvey',:position => 3)
       MailUse.create(:name => 'DeclinedSurvey',:position => 4)
  end

  def self.down
       MailUse.enumeration_model_updates_permitted = true
       
  end
end
