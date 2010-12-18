# This module contains all the helper methods used by the smerf form views.
module SurveyMailerHelper
  
  def format_group(group)
    content = ''
    question_content = ''
    
    group.questions.each do |question|
      question_content += smerf_html_group_question(question)
    end
    
    if (!question_content.blank?)
      content += content_tag(:h3, group.name) if !group.name.blank?
      content += group.description + ':' if !group.description.blank?
      content += question_content
      content += '<br/>' if !group.description.blank?
    end
    
    return content
#              <%= content_tag(:h3, group.name) if !group.name.blank? %>
#          <%= group.description + ':' if !group.description.blank? %>
#          <% group.questions.each do |question| %>
#            <%= smerf_html_group_question(question) %>
#          <% end %>
#          <%= '<br/>' if !group.description.blank? %>
  end
  #
  #
  #
  def smerf_html_group_question(question)
    content = ""

    
    # Check the type and format appropriatly
    answer = ''
    case question.type
      when 'multiplechoice'
      answer += get_multiplechoice(question)
      when 'textbox'
      answer += get_text(question)
      when 'textfield'
      answer += get_text(question)
      when 'singlechoice'
      answer += get_singlechoice(question)
      when 'selectionbox'
      answer += get_selectionbox(question)
    else  
      raise("Unknown question type for question: #{question.question}")
    end
    
    if (!answer.blank?)
      if (question.question) and (!question.question.blank?)
        content += question.question + ': '
      end
      content += answer;
      if (question.question) and (!question.question.blank?)
        content += '<br/>'
      end
    end
    
    
    return content
  end
  
  private
  
    # Some answers to questions may have further questions, here we 
    # process these sub questions.
    #
    def process_sub_questions(answer)
      # Process any answer sub quesions by recursivly calling this function
      sq_contents = ""
      if (answer.respond_to?("subquestions") and 
        answer.subquestions and answer.subquestions.size > 0)
        answer.subquestions.each {|subquestion| sq_contents += 
          smerf_html_group_question(subquestion)}
      end
      return sq_contents
    end

    # Format multiple choice question
    #
    def get_multiplechoice(question)
      contents = ""
      question.answers.each do |answer|
        # Get the user input if available
        if (@responses and !@responses.empty?() and 
          @responses.has_key?("#{question.code}") and
          @responses["#{question.code}"].has_key?("#{answer.code}"))
          user_answer = @responses["#{question.code}"]["#{answer.code}"]
          contents += content_tag(:b, answer.answer) + ', '
        end
        # Process any sub questions this answer may have
        contents += ' ' + process_sub_questions(answer)
      end
      # Process error messages if they exist
      return contents
    end

    # Format text box question
    #
    def get_text(question)
      contents = ""
      # Get the user input if available
      if (@responses and !@responses.empty?() and 
        @responses.has_key?("#{question.code}"))
        user_answer = @responses["#{question.code}"]
        if (user_answer and !user_answer.blank?())
          contents += content_tag(:b, user_answer) + ' '
        end
      end

      return contents
    end

    # Format single choice question
    #
    def get_singlechoice(question)
      contents = ""
      question.answers.each do |answer|
        # Get the user input_objects if available
        if (@responses and !@responses.empty?() and 
          @responses.has_key?("#{question.code}"))
           if ( answer.answer ) 
             user_answer = @responses["#{question.code}"]
             if ((user_answer and !user_answer.blank?() and user_answer.to_s() == answer.code.to_s()))
             contents += content_tag(:b, answer.answer) + ' '
             end
          end
        end
        # Process any sub questions this answer may have
        contents += process_sub_questions(answer)
      end
      return contents
    end
 
    # Format drop down box(select) question
    #
    def get_selectionbox(question)
      contents = ""
      question.answers.each do |answer|
        # Get the user input if available
        if (@responses and !@responses.empty?() and 
          @responses.has_key?("#{question.code}") and
          @responses["#{question.code}"].include?("#{answer.code}"))
          contents += content_tag(:b, answer.answer)
        end
      end        
      
      return contents
    end
   
end
