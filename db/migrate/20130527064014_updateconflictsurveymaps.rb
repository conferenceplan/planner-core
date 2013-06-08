class Updateconflictsurveymaps < ActiveRecord::Migration
  def self.up
      remove_column :excluded_periods_survey_maps, :survey_question
      remove_column :excluded_periods_survey_maps, :survey_code
      remove_column :excluded_periods_survey_maps, :description       
      add_column :excluded_periods_survey_maps, :survey_answer_id, :integer
      
      remove_column :excluded_items_survey_maps, :mapped_survey_question_id
      add_column :excluded_items_survey_maps, :survey_answer_id, :integer
    
   end
  

  def self.down
    add_column :excluded_periods_survey_maps, :survey_question, :text
    add_column :excluded_periods_survey_maps, :survey_code, :text
    add_column :excluded_periods_survey_maps, :description, :text
    remove_column :excluded_periods_survey_maps, :survey_answer_id
    
    add_column :excluded_items_survey_maps, :mapped_survey_question_id
    remove_column :excluded_items_survey_maps, :survey_answer_id
  end
  
end
