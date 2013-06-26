class AddExcludeEmailAnswerType < ActiveRecord::Migration
  def self.up
      AnswerType.enumeration_model_updates_permitted = true
      AnswerType.create(:name => 'DoNotShareEmail',:position => 3)
  end

  def self.down
  end
end
