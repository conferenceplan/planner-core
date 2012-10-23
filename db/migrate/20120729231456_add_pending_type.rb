class AddPendingType < ActiveRecord::Migration
  def self.up
     PendingType.enumeration_model_updates_permitted = true
     PendingType.create(:name => 'RegistrationInUse',:position => 3)
  end

  def self.down
  end
end
