class SurveySubQuestion < ActiveRecord::Base
  # belongs_to :survey_question
  belongs_to :survey_answer
  belongs_to :survey_question
end
