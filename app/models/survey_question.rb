class SurveyQuestion < ActiveRecord::Base
  has_enumerated :questionmapping, :class_name => 'QuestionMapping'

  belongs_to  :survey_group
  has_one :survey_format, :as => :formatable, :dependent => :destroy
  accepts_nested_attributes_for :survey_format
  
  has_many :survey_answers, :dependent => :delete_all
  accepts_nested_attributes_for :survey_answers, :allow_destroy => true
  
  validates_inclusion_of :question_type, :in => [:textfield, :textbox, :singlechoice, :multiplechoice, :selectionbox, :availability, :address, :phone]
  
  def question_type
    read_attribute(:question_type).to_sym
  end
  
  def question_type= (value)
    write_attribute(:question_type, value.to_s)
  end
  
  def new_answer_attributes=(answer_attributes)
    answer_attributes.each do |attributes|
      survey_answers.build(attributes)
    end
  end

  def existing_answer_attributes=(answer_attributes)
    survey_answers.reject(&:new_record?).each do |answer|
      attributes = answer_attributes[answer.id.to_s]
      if attributes && !attributes[:_destroy]
        answer.attributes = attributes
      else
        survey_answers.delete(answer)
      end
    end
  end
  
  def updateTimeConflict(params)
    if params
      survey_answers.each do |answer|
        attr = params[answer.id.to_s]
        answer.updateTimeConflict(attr) if attr
      end
    end
  end
  
end
