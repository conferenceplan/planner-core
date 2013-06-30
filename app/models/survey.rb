class Survey < ActiveRecord::Base

  # Survey contains a series of groups, groups contain a series of questions
  has_many :survey_groups, :dependent => :destroy, :order => 'sort_order asc'

  has_many :survey_responses
  
  def getAllQuestions
    res = Array.new
    
    # get the groups and from them get all the questions
    survey_groups.each do |grp|
       res.concat(grp.survey_questions)
    end
    
    return res
  end
  
end
