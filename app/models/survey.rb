class Survey < ActiveRecord::Base

  # Survey contains a series of groups, groups contain a series of questions
  has_one :survey_group, :dependent => :delete
  
end
