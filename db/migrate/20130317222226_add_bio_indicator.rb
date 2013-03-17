class AddBioIndicator < ActiveRecord::Migration
  def self.up
    add_column :survey_questions, :isbio, :boolean
    add_column :survey_responses, :isbio, :boolean
  end

  def self.down
		remove_column :survey_questions, :isbio
    remove_column :survey_responses, :isbio
  end
end
