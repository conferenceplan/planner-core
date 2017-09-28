
require 'programme_item'
require 'published_programme_item'

class CopyPrecisToDescriptionForProgrammeItems < ActiveRecord::Migration
  def up
    I18n.with_locale(:en) do
      ProgrammeItem.find_in_batches do |group|
        group.each do |item|
          item.update(
            description: item.get_precis, 
            short_description: item.short_precis
          )
        end
      end
      PublishedProgrammeItem.find_in_batches do |group|
        group.each do |item|
          item.update(
            description: item.get_precis
          )
        end
      end
    end
  end

  def down
  end
end

