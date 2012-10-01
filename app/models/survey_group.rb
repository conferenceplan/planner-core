class SurveyGroup < ActiveRecord::Base
  
  belongs_to  :survey
  has_one :survey_format, :as => :formatable, :dependent => :destroy
  accepts_nested_attributes_for :survey_format

  has_many :survey_questions, :dependent => :destroy, :order => 'sort_order asc'
 
end
