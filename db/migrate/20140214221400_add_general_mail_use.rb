class AddGeneralMailUse < ActiveRecord::Migration
  def up
    MailUse.enumeration_model_updates_permitted = true
    MailUse.create(:name => 'General',:position => 5)
  end

  def down
  end
end
