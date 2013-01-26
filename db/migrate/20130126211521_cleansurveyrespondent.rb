class Cleansurveyrespondent < ActiveRecord::Migration
  def self.up
    remove_column :survey_respondents, :first_name
    remove_column :survey_respondents, :last_name
    remove_column :survey_respondents, :suffix
    remove_column :survey_respondents, :prefix
    remove_column :survey_respondents, :email
  end

  def self.down
    add_column :survey_respondents, :answer_type, :first_name
    add_column :survey_respondents, :answer_type, :last_name
    add_column :survey_respondents, :answer_type, :suffix
    add_column :survey_respondents, :answer_type, :prefix
    add_column :survey_respondents, :answer_type, :email
  end
end
