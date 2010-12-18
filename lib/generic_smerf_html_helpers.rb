# This module contains all the helper methods used by the smerf form views.
module GenericSmerfHtmlHelper
  
  #
  #
  #
  def smerf_html_group_question(question)
    content = ""

    if (question.question) and (!question.question.blank?)
      content += content_tag(:div, question.question ) 
    end
    
    # Check the type and format appropriatly
    case question.type
      when 'multiplechoice'
      content += get_multiplechoice(question)
      when 'textbox'
      content += get_text(question)
      when 'textfield'
      content += get_text(question)
      when 'singlechoice'
      content += get_singlechoice(question)
      when 'selectionbox'
      content += get_selectionbox(question)
    else  
      raise("Unknown question type for question: #{question.question}")
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
#          contents += content_tag(:div, user_answer)
          contents += content_tag(:div, answer.answer)
        end
        # Process any sub questions this answer may have
        contents += process_sub_questions(answer)
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
          contents += content_tag(:div, user_answer)
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
             contents += content_tag(:div, answer.answer)
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
#          contents += content_tag(:div, answer.code.to_s())
          contents += content_tag(:div, answer.answer)
        end
      end        
      
      return contents
    end
   
end
