class CreateExcludedPeriodsSurveyMaps < ActiveRecord::Migration
  def self.up
     create_table :excluded_periods_survey_maps do |t|     
       t.integer :period_id
       t.string :period_type
       t.text :survey_question
       t.text :survey_code
       t.text :description
       t.timestamps
       t.column :lock_version, :integer, { :default => 0 }   
      end
  end

  def self.down
    drop_table :excluded_periods_survey_maps
  end
end
