class FixSurveyTables < ActiveRecord::Migration
  def self.up 
    add_column :survey_questions, :answer_type, :string, :default => "String"
    
    add_column :survey_questions, :answer1_type, :string, :default => "String"
    add_column :survey_questions, :question1, :text
    add_column :survey_formats, :help1, :text
    
    add_column :survey_questions, :answer2_type, :string, :default => "String"
    add_column :survey_questions, :question2, :text
    add_column :survey_formats, :help2, :text
    
    add_column :survey_questions, :answer3_type, :string, :default => "String"
    add_column :survey_questions, :question3, :text
    add_column :survey_formats, :help3, :text
    
    add_column :survey_questions, :answer4_type, :string, :default => "String"
    add_column :survey_questions, :question4, :text
    add_column :survey_formats, :help4, :text
    
    add_column :survey_questions, :answer5_type, :string, :default => "String"
    add_column :survey_questions, :question5, :text
    add_column :survey_formats, :help5, :text

    add_column :survey_questions, :answer6_type, :string, :default => "String"
    add_column :survey_questions, :question6, :text
    add_column :survey_formats, :help6, :text

    change_column :survey_questions, :question, :text
    change_column :survey_answers, :answer, :text
    change_column :survey_answers, :help, :text
    
    add_column :survey_responses, :response1, :text
    add_column :survey_responses, :response2, :text
    add_column :survey_responses, :response3, :text
    add_column :survey_responses, :response4, :text
    add_column :survey_responses, :response5, :text
    add_column :survey_responses, :response6, :text
  end

  def self.down
    remove_column :survey_questions, :answer_type
    
    remove_column :survey_questions, :answer1_type
    remove_column :survey_questions, :question1
    remove_column :survey_formats, :help1
    
    remove_column :survey_questions, :answer2_type
    remove_column :survey_questions, :question2
    remove_column :survey_formats, :help2
    
    remove_column :survey_questions, :answer3_type
    remove_column :survey_questions, :question3
    remove_column :survey_formats, :help3
    
    remove_column :survey_questions, :answer4_type
    remove_column :survey_questions, :question4
    remove_column :survey_formats, :help4
    
    remove_column :survey_questions, :answer5_type
    remove_column :survey_questions, :question5
    remove_column :survey_formats, :help5
    
    remove_column :survey_questions, :answer6_type
    remove_column :survey_questions, :question6
    remove_column :survey_formats, :help6
    
    remove_column :survey_responses, :response1
    remove_column :survey_responses, :response2
    remove_column :survey_responses, :response3
    remove_column :survey_responses, :response4
    remove_column :survey_responses, :response5
    remove_column :survey_responses, :response6
  end
end
