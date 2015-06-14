require 'enum'
require 'answer_type'

class AddAvailableTimeAnswerType < ActiveRecord::Migration
  def up
      AnswerType.enumeration_model_updates_permitted = true
      AnswerType.create(:name => 'AvailableTime',:position => 5)
  end

  def down
  end
end
