class Survey < ActiveRecord::Base

  # Survey contains a series of groups, groups contain a series of questions
  has_many :survey_groups, :dependent => :destroy
  
end
