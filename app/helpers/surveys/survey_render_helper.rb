module Surveys::SurveyRenderHelper

    def format_group(group)
      content = ''
      question_content = ''
      
      # Put in the group information...
      
      # for each :survey_questions
      group.survey_questions.each do |question|
        # insert the question
        question_content += group_question(question)
      end

      if (!question_content.blank?)
        if !group.name.blank?
          content += content_tag(:h3, group.name, :class => :response_group_header)
        else
          content += content_tag(:h3, group.altname, :class => :response_group_header) if !group.altname.blank?
        end
        content += content_tag(:div, question_content, :class => :response_group_body)
      end
      
      return content
    end
    
  def group_help(group)
    if group.survey_format && !group.survey_format.help.blank?
      "<a title='"+group.help+"' >"+image_tag("smerf_help.gif", :alt => "Help")+"</a>"
    end
  end

end

  # def add_answer_link(name, elementid) 
    # link_to_function name do |page|
      # page.insert_html :bottom, elementid, :partial => 'answer_form', :object => SurveyAnswer.new
    # end 
  # end
