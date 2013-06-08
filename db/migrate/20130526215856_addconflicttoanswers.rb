class Addconflicttoanswers < ActiveRecord::Migration
  def self.up
      add_column :survey_answers, :answertype_id, :integer
      add_column :survey_answers, :start_time, :text
      add_column :survey_answers, :start_day, :integer
      add_column :survey_answers, :duration, :integer
  end

  def self.down
      remove_column :survey_answers, :answertype_id
      remove_column :survey_answers, :start_time
      remove_column :survey_answers, :start_day
      remove_column :survey_answers, :duration
  end
end
