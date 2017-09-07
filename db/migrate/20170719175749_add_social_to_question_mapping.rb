require "enum"
require "planner_ui/token_type"

class AddSocialToQuestionMapping < ActiveRecord::Migration
  def up
    QuestionMapping.enumeration_model_updates_permitted = true
    QuestionMapping.create(:name => 'LinkedIn',:position => 9)
    QuestionMapping.create(:name => 'YouTube',:position => 10)
    QuestionMapping.create(:name => 'Twitch',:position => 11)
    QuestionMapping.create(:name => 'Instagram',:position => 12)
    QuestionMapping.create(:name => 'Flickr',:position => 13)
    QuestionMapping.create(:name => 'Reddit',:position => 14)
  end

  def down
    QuestionMapping.enumeration_model_updates_permitted = true
    QuestionMapping['LinkedIn'].destroy if QuestionMapping['LinkedIn']
    QuestionMapping['YouTube'].destroy if QuestionMapping['YouTube']
    QuestionMapping['Twitch'].destroy if QuestionMapping['Twitch']
    QuestionMapping['Instagram'].destroy if QuestionMapping['Instagram']
    QuestionMapping['Flickr'].destroy if QuestionMapping['Flickr']
    QuestionMapping['Reddit'].destroy if QuestionMapping['Reddit']
  end
end
