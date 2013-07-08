class AddHasSurvey < ActiveRecord::Migration
  def self.up
    add_column :survey_respondents, :submitted_survey, :boolean, :default => false
  end

  def self.down
    remove_column :survey_respondents, :submitted_survey
  end
end
