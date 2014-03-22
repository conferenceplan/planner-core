class AddListIndexes < ActiveRecord::Migration
  def up
    add_index :survey_responses, [:survey_question_id], :name => 'survey_resp_question_idx'
    add_index :survey_responses, [:survey_respondent_detail_id], :name => 'survey_resp_detail_idx'
    
    add_index :survey_groups, [:survey_id], :name => 'survey_grp_survey_idx'
    
    add_index :surveys, [:alias], :name => 'survey_alias_idx'
  end

  def down
    remove_index :survey_responses, :name => 'survey_resp_question_idx'
    remove_index :survey_responses, :name => 'survey_resp_detail_idx'
    remove_index :survey_groups, :name => 'survey_grp_survey_idx'
    remove_index :surveys, :name => 'survey_alias_idx'
  end
end
