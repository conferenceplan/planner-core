class AddNamechangePendingtype < ActiveRecord::Migration
  def self.up
     PendingType.enumeration_model_updates_permitted = true
     PendingType.create(:name => 'PossibleNameUpdate',:position => 4)
  end

  def self.down
  end
end
