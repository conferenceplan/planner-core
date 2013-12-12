class AddPrivateToQuestion < ActiveRecord::Migration
  def self.up
    add_column :survey_questions, :private, :boolean, { :default => 0 }
  end

  def self.down
    remove_column :survey_questions, :private
  end
end
