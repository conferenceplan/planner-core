class SurveyAnswer < ActiveRecord::Base
  # has_many :survey_sub_questions
  # has_many :survey_questions, :through => :survey_sub_questions
  
  belongs_to :survey_question
end
