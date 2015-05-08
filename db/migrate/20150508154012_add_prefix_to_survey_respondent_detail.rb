class AddPrefixToSurveyRespondentDetail < ActiveRecord::Migration
  def change
    add_column :survey_respondent_details, :prefix, :string, {:default => ""}
  end
end
