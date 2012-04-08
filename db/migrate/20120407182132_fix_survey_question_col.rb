class FixSurveyQuestionCol < ActiveRecord::Migration
  def self.up
		rename_column :survey_questions, :type, :question_type
  end

  def self.down
		rename_column :survey_questions, :question_type, :type
  end
end
