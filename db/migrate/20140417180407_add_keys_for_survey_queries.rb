class AddKeysForSurveyQueries < ActiveRecord::Migration
  def up
    add_index :survey_responses, [:survey_id], :name => 'survey_idx'
    add_index :survey_respondent_details, [:survey_respondent_id], :name => 'survey_resp_idx'
    add_index :survey_respondents, [:person_id], :name => 'survey_resp_person_idx'
  end

  def down
    remove_index :survey_responses, :name => 'survey_idx'
    remove_index :survey_respondent_details, :name => 'survey_resp_idx'
    remove_index :survey_respondents, :name => 'survey_resp_person_idx'
  end
end
