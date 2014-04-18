class AddDaysToQuestionMapping < ActiveRecord::Migration
  def change
      QuestionMapping.enumeration_model_updates_permitted = true
      QuestionMapping.create(:name => 'ItemsPerDay',:position => 7)
      QuestionMapping.create(:name => 'ItemsPerConference',:position => 8)
  end
end
