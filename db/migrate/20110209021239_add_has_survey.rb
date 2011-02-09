class AddHasSurvey < ActiveRecord::Migration
  def self.up
    add_column :survey_respondents, :submitted_survey, :boolean, :default => false

    # ensure that it is true for existing respondents that have filled in the survey
    execute "update survey_respondents set submitted_survey = true where id in (SELECT form.surveyrespondent_id FROM smerf_forms_surveyrespondents form)"
  end

  def self.down
    remove_column :survey_respondents, :submitted_survey
  end
end
