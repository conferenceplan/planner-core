class UpdateSurveyRespondent < ActiveRecord::Migration
  def up
    remove_column :survey_respondents, :persistence_token
    remove_column :survey_respondents, :single_access_token
  end

  def down
    add_column :survey_respondents, :persistence_token, :string
    add_column :survey_respondents, :single_access_token, :string
  end
end
