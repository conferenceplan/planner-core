require 'programme_item'
require 'published_programme_item'

class AddTranslationTablesForProgrammeItems < ActiveRecord::Migration
  def up
    I18n.with_locale(:en) do
      ProgrammeItem.create_translation_table!(
        {
          :title => :string,
          :short_title => :string,
          :description => :text,
          :short_description => :text
        }, 
        {
          :migrate_data => true
        }
      )
      PublishedProgrammeItem.create_translation_table!(
        {
          :title => :string,
          :short_title => :string,
          :description => :text
        }, 
        {
          :migrate_data => true
        }
      )
    end
  end

  def down
    ProgrammeItem.drop_translation_table! :migrate_data => true
    PublishedProgrammeItem.drop_translation_table! :migrate_data => true
  end
end
