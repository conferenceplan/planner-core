module Surveys::SurveyGroups::SurveyQuestionsHelper

  def add_answer_link(name, elementid) 
    link_to_function name do |page|
      page.insert_html :bottom, elementid, :partial => 'answer_form', :object => SurveyAnswer.new
    end 
  end
  def getDayConflictCollection()
     
      dayCollection = (0..((SITE_CONFIG[:conference][:number_of_days]).to_i-1)).to_a.collect{ |r| [(Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + r.days).strftime('%A'), r]}
      allArray = ["All", (SITE_CONFIG[:conference][:number_of_days]).to_i]
      dayCollection[(SITE_CONFIG[:conference][:number_of_days]).to_i] = allArray
      return dayCollection
  end

end
