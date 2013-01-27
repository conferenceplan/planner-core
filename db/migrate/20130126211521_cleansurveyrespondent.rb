class Cleansurveyrespondent < ActiveRecord::Migration
  def self.up
    remove_column :survey_respondents, :first_name
    remove_column :survey_respondents, :last_name
    remove_column :survey_respondents, :suffix
    remove_column :survey_respondents, :prefix
    remove_column :survey_respondents, :email
  end

  def self.down
    add_column :survey_respondents, :first_name, :string
    add_column :survey_respondents, :last_name, :string
    add_column :survey_respondents, :suffix, :string
    add_column :survey_respondents, :prefix, :string
    add_column :survey_respondents, :email, :string
  end
end
