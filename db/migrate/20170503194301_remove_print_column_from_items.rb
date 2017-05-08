require 'programme_item'
require "enum"
require "target_audience"

class RemovePrintColumnFromItems < ActiveRecord::Migration
  def up
    remove_column :programme_items, :print
  end

  def down
    add_column :programme_items, :print, :boolean, nil: false, default: true
    ProgrammeItem.where(target_audience_id: TargetAudience['None'].id).update_all(print: false)
  end
end
