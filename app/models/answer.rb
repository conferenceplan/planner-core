#
# TODO - check if used
#
class Answer < ActiveRecord::Base
  attr_accessible :lock_version, :question, :reply, :survey_id
  
  belongs_to  :survey
end
