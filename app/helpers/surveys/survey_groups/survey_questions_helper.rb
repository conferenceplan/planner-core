module Surveys::SurveyGroups::SurveyQuestionsHelper

  def add_answer_link(name, elementid) 
    link_to_function name do |page|
      page.insert_html :bottom, elementid, :partial => 'answer_form', :object => SurveyAnswer.new
    end 
  end

end
