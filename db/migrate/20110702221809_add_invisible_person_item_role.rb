class AddInvisiblePersonItemRole < ActiveRecord::Migration
  def self.up
      PersonItemRole.enumeration_model_updates_permitted = true
      PersonItemRole.create(:name => 'Invisible',:position => 6)
  end

  def self.down
  end
end
