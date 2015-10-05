class SurveyResponse < ActiveRecord::Base
  attr_accessible :lock_version, :response, :response1, :response2, :response3, :response4, :response5, :response6, :isbio,
                  :survey_question_id, :survey_respondent_detail, :survey_id, :photo, :photo_cache, :survey_answer_id

  mount_uploader :photo, BioPictureUploader

  belongs_to :survey_respondent_detail
  belongs_to :survey_question
  
  belongs_to :survey
  
end
