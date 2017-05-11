require 'programme_item'
require "enum"
require "visibility"

class RemovePrintColumnFromItems < ActiveRecord::Migration
  def up
    remove_column :programme_items, :print
  end

  def down
    add_column :programme_items, :print, :boolean, nil: false, default: true
    ProgrammeItem.where(visibility_id: Visibility['None'].id).update_all(print: false)
  end
end
