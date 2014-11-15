class Dbcleanup < ActiveRecord::Migration
  def up
    drop_table :mapped_survey_questions if ActiveRecord::Base.connection.table_exists? :mapped_survey_questions
    drop_table :menu_items if ActiveRecord::Base.connection.table_exists? :menu_items
    drop_table :menus if ActiveRecord::Base.connection.table_exists? :menus
    drop_table :messages if ActiveRecord::Base.connection.table_exists? :messages
    drop_table :pending_publication_items if ActiveRecord::Base.connection.table_exists? :pending_publication_items
    drop_table :preferences if ActiveRecord::Base.connection.table_exists? :preferences
    drop_table :room_free_times if ActiveRecord::Base.connection.table_exists? :room_free_times
    drop_table :schedules if ActiveRecord::Base.connection.table_exists? :schedules
    drop_table :smerf_forms if ActiveRecord::Base.connection.table_exists? :smerf_forms
    drop_table :smerf_forms_surveyrespondents if ActiveRecord::Base.connection.table_exists? :smerf_forms_surveyrespondents
    drop_table :smerf_responses if ActiveRecord::Base.connection.table_exists? :smerf_responses
    drop_table :survey_copy_statuses if ActiveRecord::Base.connection.table_exists? :survey_copy_statuses
  end
end
