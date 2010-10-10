class SurveyRespondentAddAttending < ActiveRecord::Migration
  def self.up
    add_column :survey_respondents, :attending, :boolean, :default => true
  end

  def self.down
  end
end
