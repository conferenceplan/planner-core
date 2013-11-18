class CreateExcludedItemSurveyMap < ActiveRecord::Migration
 
 def self.up
     create_table :mapped_survey_questions do |t|
       t.text :question
       t.text :code
       t.text :name
       t.timestamps
       t.column :lock_version, :integer, { :default => 0 }
       
   end
   
   create_table :excluded_items_survey_maps do |t|     
       t.references :programme_item
       t.references :mapped_survey_question
       t.timestamps
       t.column :lock_version, :integer, { :default => 0 }
   end

 end

  
  def self.down
    drop_table  :excluded_items_survey_maps
    drop_table :mapped_survey_questions
  end
  
end
