class AddSuffuxToSurveyRespondent < ActiveRecord::Migration
  def self.up
    add_column :survey_respondents, :suffix, :string
  end

  def self.down
    remove_column :survey_respondents, :suffix
  end
end
