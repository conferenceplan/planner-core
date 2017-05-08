require 'programme_item'
require 'published_programme_item'
require "enum"
require "target_audience"

class SetTargetAudienceForItems < ActiveRecord::Migration
  def up
    ProgrammeItem.where(print: true).update_all(target_audience_id: TargetAudience['Public'].id)
    ProgrammeItem.where(print: false).update_all(target_audience_id: TargetAudience['None'].id)
    ProgrammeItem.where(print: nil).update_all(target_audience_id: TargetAudience['None'].id)
    PublishedProgrammeItem.update_all(target_audience_id: TargetAudience['Public'].id)
  end

  def down
    ProgrammeItem.update_all(target_audience_id: nil)
    PublishedProgrammeItem.update_all(target_audience_id: nil)
  end
end
