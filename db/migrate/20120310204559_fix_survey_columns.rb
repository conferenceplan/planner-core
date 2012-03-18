class FixSurveyColumns < ActiveRecord::Migration
  def self.up
     remove_column :survey_groups, :Survey_id
     add_column :survey_groups, :survey_id, :integer

     remove_column :survey_questions, :SurveyGroup_id
     add_column :survey_questions, :survey_group_id, :integer

     remove_column :survey_responses, :Survey_id
     add_column :survey_responses, :survey_id, :integer
     remove_column :survey_responses, :SurveyQuestion_id
     add_column :survey_responses, :survey_question_id, :integer
     remove_column :survey_responses, :Person_id
     add_column :survey_responses, :person_id, :integer

     remove_column :survey_sub_questions, :SurveyQuestion_id
     add_column :survey_sub_questions, :survey_question_id, :integer
     remove_column :survey_sub_questions, :SurveyAnswer_id
     add_column :survey_sub_questions, :survey_answer_id, :integer

     remove_column :survey_assignments, :Person_id
     add_column :survey_assignments, :person_id, :integer
     remove_column :survey_assignments, :SurveyResponse_id
     add_column :survey_assignments, :survey_response_id, :integer

     remove_column :survey_answers, :SurveyQuestion_id
     add_column :survey_answers, :survey_question_id, :integer
  end

  def self.down
     remove_column :survey_groups, :survey_id
     add_column :survey_groups, :Survey_id, :integer

     remove_column :survey_questions, :survey_group_id
     add_column :survey_questions, :SurveyGroup_id, :integer

     remove_column :survey_responses, :survey_id
     add_column :survey_responses, :Survey_id, :integer
     remove_column :survey_responses, :survey_question_id
     add_column :survey_responses, :SurveyQuestion_id, :integer
     remove_column :survey_responses, :person_id
     add_column :survey_responses, :Person_id, :integer

     remove_column :survey_sub_questions, :survey_question_id
     add_column :survey_sub_questions, :SurveyQuestion_id, :integer
     remove_column :survey_sub_questions, :survey_answer_id
     add_column :survey_sub_questions, :SurveyAnswer_id, :integer

     remove_column :survey_assignments, :person_id
     add_column :survey_assignments, :Person_id, :integer
     remove_column :survey_assignments, :survey_response_id
     add_column :survey_assignments, :SurveyResponse_id, :integer

     remove_column :survey_answers, :survey_question_id
     add_column :survey_answers, :SurveyQuestion_id, :integer
  end
end
