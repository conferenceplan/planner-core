class SurveyQuestion < ActiveRecord::Base
  
  belongs_to  :survey_group
  
  validates_inclusion_of :question_type, :in => [:multiplechoice, :textbox, :singlechoice, :textfield, :selectionbox]
  
  def question_type
    read_attribute(:question_type).to_sym
  end
  
  def question_type= (value)
    write_attribute(:question_type, value.to_s)
  end
  
end
