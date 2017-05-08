require "enum"
require "target_audience"

class CreateInitialTargetAudienceEnums < ActiveRecord::Migration
  def up
    TargetAudience.enumeration_model_updates_permitted = true
    TargetAudience.create(:name => 'None', :position => 1)
    TargetAudience.create(:name => 'Private', :position => 2)
    TargetAudience.create(:name => 'Registrants', :position => 3)
    TargetAudience.create(:name => 'Public', :position => 4)
  end

  def down
    TargetAudience.enumeration_model_updates_permitted = true
    TargetAudience['None'].destroy if TargetAudience['None']
    TargetAudience['Private'].destroy if TargetAudience['Private']
    TargetAudience['Registrants'].destroy if TargetAudience['Registrants']
    TargetAudience['Public'].destroy if TargetAudience['Public']
  end
end
