class SurveyQuestion < ActiveRecord::Base
  
  belongs_to  :survey_group
  has_one :survey_format, :as => :formatable, :dependent => :destroy
  accepts_nested_attributes_for :survey_format
  
  has_many :survey_answers, :dependent => :destroy
  accepts_nested_attributes_for :survey_answers
  
  validates_inclusion_of :question_type, :in => [:textfield, :textbox, :singlechoice, :multiplechoice, :selectionbox]
  
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

  after_update :save_survey_answers
  validates_associated :save_survey_answers

  def existing_answer_attributes=(answer_attributes)
    survey_answers.reject(&:new_record?).each do |answer|
      attributes = answer_attributes[answer.id.to_s]
      if attributes
        answer.attributes = attributes
      else
        survey_answers.delete(answer)
      end
    end
  end
  
  def save_survey_answers
     survey_answers.each do |answer|
       answer.save(false)
     end
  end
  
end
