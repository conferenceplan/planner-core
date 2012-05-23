class SurveyQuestion < ActiveRecord::Base
  
  belongs_to  :survey_group
  has_one :survey_format, :as => :formatable, :dependent => :destroy
  accepts_nested_attributes_for :survey_format
  
  has_many :survey_answers
  # accepts_nested_attributes_for :survey_answers
  
  validates_inclusion_of :question_type, :in => [:textfield, :textbox, :singlechoice, :multiplechoice, :selectionbox]
  
  def question_type
    read_attribute(:question_type).to_sym
  end
  
  def question_type= (value)
    write_attribute(:question_type, value.to_s)
  end
  
end
