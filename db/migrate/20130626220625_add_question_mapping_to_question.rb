class AddQuestionMappingToQuestion < ActiveRecord::Migration
  def self.up
    add_column :survey_questions, :questionmapping_id, :integer
  end

  def self.down
    remove_column :survey_questions, :questionmapping_id
  end
end
