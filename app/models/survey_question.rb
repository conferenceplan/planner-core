class SurveyQuestion < ActiveRecord::Base
  # audited :allow_mass_assignment => true
  
  has_enumerated :questionmapping, :class_name => 'QuestionMapping'

  belongs_to  :survey_group
  has_one :survey_format, :as => :formatable, :dependent => :destroy
  accepts_nested_attributes_for :survey_format
  
  has_many :survey_answers, :dependent => :destroy
  accepts_nested_attributes_for :survey_answers, :allow_destroy => true
  
  validates_inclusion_of :question_type, :in => [:textfield, :textbox, :singlechoice, :multiplechoice, :selectionbox, :availability, :address, :phone]
  
  def question_type
    read_attribute(:question_type).to_sym
  end
  
  def question_type= (value)
    write_attribute(:question_type, value.to_s)
  end
  
  def update_answers(new_answers) # A collection of answers that have been passed in
    
    # If the answer is new then create one and add it (i.e. answer does not have an id)
    # If the answer has an id then update the value
    # Any left over are for deletion
    
    updates = Hash[ new_answers.map { |a| (a[:id] ? [a[:id], a] : nil) }.compact ]
    newAnswers = new_answers.collect { |a| (a[:id] ? nil : a) }.compact

    survey_answers.each do |answer|
      if updates[answer.id]
        answer.update_attributes( updates[answer.id] )
      else
        # delete it and remove it from the collection
        candidate = survey_answers.delete(answer)
      end
    end
    
    # now create the new ones
    newAnswers.each do |answer|
      survey_answers << SurveyAnswer.new(answer)
    end
    
    updateTimeConflicts
    
  end

private
  
  def updateTimeConflicts
    survey_answers.each do |answer|
      answer.updateTimeConflicts
    end
  end
  
end
