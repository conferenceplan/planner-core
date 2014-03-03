require 'enum'
require 'answer_type'

class AddAnswerTypeEnum < ActiveRecord::Migration
  def self.up
      AnswerType.enumeration_model_updates_permitted = true
      AnswerType.create(:name => 'Simple',:position => 1)
      AnswerType.create(:name => 'ItemConflict',:position => 2)
      AnswerType.create(:name => 'TimeConflict',:position => 3)
  end

  def self.down
  end
end
