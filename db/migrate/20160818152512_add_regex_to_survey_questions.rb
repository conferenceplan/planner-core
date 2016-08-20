class AddRegexToSurveyQuestions < ActiveRecord::Migration
  def change
    add_column :survey_questions, :regex, :string
  end
end
