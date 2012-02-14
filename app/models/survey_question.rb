class SurveyQuestion < ActiveRecord::Base
  
  belongs_to  :survey_group
  
  validates_inclusion_of :type, :in => [:multiplechoice, :textbox, :singlechoice, :textfield, :selectionbox]
  
  def type
    read_attribute(:type).to_sym
  end
  
  def type= (value)
    write_attribute(:type, value.to_s)
  end
  
end
