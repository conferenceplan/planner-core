class AddEmailToSurveyRespodent < ActiveRecord::Migration
  def self.up
    add_column :survey_respondents, :email, :string
  end

  def self.down
    remove_column :survey_respondents, :email
  end
end
