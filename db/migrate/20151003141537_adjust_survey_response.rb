class AdjustSurveyResponse < ActiveRecord::Migration
  def change
    add_column :survey_responses, :survey_answer_id, :integer
  end
end
