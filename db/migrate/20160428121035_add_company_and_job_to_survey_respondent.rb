class AddCompanyAndJobToSurveyRespondent < ActiveRecord::Migration
  def change
    add_column :survey_respondent_details, :company, :string
    add_column :survey_respondent_details, :job_title, :string
  end
end
