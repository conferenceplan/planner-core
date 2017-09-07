require 'programme_item'
require 'published_programme_item'
require "enum"
require "visibility"

class SetVisibilityForItems < ActiveRecord::Migration
  def up
    ProgrammeItem.where(print: true).update_all(visibility_id: Visibility['Public'].id)
    ProgrammeItem.where(print: false).update_all(visibility_id: Visibility['None'].id)
    ProgrammeItem.where(print: nil).update_all(visibility_id: Visibility['None'].id)
    PublishedProgrammeItem.update_all(visibility_id: Visibility['Public'].id)
  end

  def down
    ProgrammeItem.update_all(visibility_id: nil)
    PublishedProgrammeItem.update_all(visibility_id: nil)
  end
end
