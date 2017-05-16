require "enum"
require "visibility"

class CreateInitialVisibilityEnums < ActiveRecord::Migration
  def up
    Visibility.enumeration_model_updates_permitted = true
    Visibility.create(:name => 'None', :position => 1)
    Visibility.create(:name => 'Private', :position => 2)
    Visibility.create(:name => 'Registrants', :position => 3)
    Visibility.create(:name => 'Public', :position => 4)
  end

  def down
    Visibility.enumeration_model_updates_permitted = true
    Visibility['None'].destroy if Visibility['None']
    Visibility['Private'].destroy if Visibility['Private']
    Visibility['Registrants'].destroy if Visibility['Registrants']
    Visibility['Public'].destroy if Visibility['Public']
  end
end
