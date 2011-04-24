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
   
 

   val = MappedSurveyQuestion.new
   val.name = "Tim Powers GoH Item"
   val.code = "1"
   val.question = "g6q5"
   val.save


   val = MappedSurveyQuestion.new
   val.name = "Boris Vallejo GoH Item"
   val.code = "2"
   val.question = "g6q5"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "Ellen Asher GoH Item"
   val.code = "3"
   val.question = "g6q5"  
   val.save

   val = MappedSurveyQuestion.new
   val.name = "Charles N. Brown GoH Item"
   val.code = "4"
   val.question = "g6q5"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "Bill Willingham Item"
   val.code = "5"
   val.question = "g6q5"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "Tricky Pixie Item"
   val.code = "6"
   val.question = "g6q5"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "Opening Ceremony"
   val.code = "1"
   val.question = "g6q6"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "Chesley Awards"
   val.code = "2"
   val.question = "g6q6"
   val.save
 
   val = MappedSurveyQuestion.new
   val.name = "Masquerad"
   val.code = "3"
   val.question = "g6q6"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "Hugo Ceremony"
   val.code = "4"
   val.question = "g6q6"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "Closing Ceremony"
   val.code = "5"
   val.question = "g6q6"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "Tricky Pixie Concert"
   val.code = "6"
   val.question = "g6q6"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "WSFS Meetings"
   val.code = "7"
   val.question = "g6q6"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "SFWA Meeting"
   val.code = "8"
   val.question = "g6q6"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "ASFA Meeting"
   val.code = "9"
   val.question = "g6q6"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "Masq Rehearsal"
   val.code = "10"
   val.question = "g6q6"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "Art Auction"
   val.code = "11"
   val.question = "g6q6"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "Regency Dance"
   val.code = "12"
   val.question = "g6q6"
   val.save

   val = MappedSurveyQuestion.new
   val.name = "Charity and Fan Fund Auctions"
   val.code = "13"
   val.question = "g6q6"
   val.save

 end

  
  def self.down
    drop_table  :excluded_items_survey_maps
    drop_table :mapped_survey_questions
  end
  
end
