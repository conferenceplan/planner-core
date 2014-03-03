require 'enum'
require 'question_mapping'

class AddQuestionMappingEnum < ActiveRecord::Migration
  def self.up
      QuestionMapping.enumeration_model_updates_permitted = true
      QuestionMapping.create(:name => 'None',:position => 1)
      QuestionMapping.create(:name => 'WebSite',:position => 2)
      QuestionMapping.create(:name => 'Twitter',:position => 3)
      QuestionMapping.create(:name => 'OtherSocialMedia',:position => 4)
      QuestionMapping.create(:name => 'Photo',:position => 5)
      QuestionMapping.create(:name => 'Facebook',:position => 6)
  end

  def self.down
  end
end
