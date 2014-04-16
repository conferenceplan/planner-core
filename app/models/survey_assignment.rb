class SurveyAssignment < ActiveRecord::Base
  attr_accessible :lock_version, :person_id, :survey_response_id
end
