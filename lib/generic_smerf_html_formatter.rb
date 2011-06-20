#
#
#
module GenericSmerfHtmlFormatter
  
  #
  #
  #
  def html_format_group(group)
    content = ''
    question_content = ''
    
    group.questions.each do |question|
      question_content += html_group_question(question)
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

  def html_group_question(question)
    content = ""
    answer_html = ""
    okToShow = true
    
    # Check the type and format appropriatly
    answer = ''
    if question.code == 'g93q6'
      okToShow = false
      controller.permitted_to? :supermanage, :survey_respondents_reviews do
        okToShow = true
      end
    end
    if okToShow
      case question.type
        when 'multiplechoice'
        answer += html_get_multiplechoice(question)
        when 'textbox'
        answer += html_get_textbox(question)
        when 'textfield'
        answer += html_get_text(question)
        when 'singlechoice'
        answer += html_get_singlechoice(question)
        when 'selectionbox'
        answer += html_get_selectionbox(question)
      else  
        raise("Unknown question type for question: #{question.question}")
      end
      
      if (!answer.blank?)
        if (question.question) and (!question.question.blank?)
          answer_html += content_tag(:div, question.question, :class => 'response_question_text')
        end
        answer_html += content_tag(:div, answer, :class => 'response_answer')
        #      content += content_tag(:div, answer_html, :class => 'response_question')
        content = answer_html
      end
      
      if question.additional
        # for each of the additional we want to create a new version of the same question
        1.upto(question.additional) { |i|
          dup_question = question.clone
          dup_question.additional = 0
          dup_question.code += "-" + i.to_s
          html_change_question_code(dup_question, "-" + i.to_s)
          # need to go through the nested questions and change their codes as well
          content += html_group_question(dup_question)        
        }
      end
    end
    
    return content
  end
  
  private
    def html_change_question_code(question, code)
      question.answers.each do |answer|
        if (answer.respond_to?("subquestions") and answer.subquestions and answer.subquestions.size > 0)
        answer.subquestions.each {|subquestion| 
           subquestion.code += code
           html_change_question_code(subquestion, code)
          }
        end
      end
    end

    # Some answers to questions may have further questions, here we 
    # process these sub questions.
    #
    def html_process_sub_questions(answer)
      # Process any answer sub quesions by recursivly calling this function
      sq_contents = ""
      if (answer.respond_to?("subquestions") and 
        answer.subquestions and answer.subquestions.size > 0)
        answer.subquestions.each {|subquestion| sq_contents += 
          html_group_question(subquestion)}
      end
      return sq_contents
    end

    # Format multiple choice question
    #
    def html_get_multiplechoice(question)
      contents = ""
      question.answers.each do |answer|
        # Get the user input if available
        if (@responses and !@responses.empty?() and 
          @responses.has_key?("#{question.code}") and
          @responses["#{question.code}"].has_key?("#{answer.code}"))
          user_answer = @responses["#{question.code}"]["#{answer.code}"]
          contents += content_tag(:div, answer.answer, :class => 'response_choice')
        end
        # Process any sub questions this answer may have
        contents += ' ' + html_process_sub_questions(answer)
      end
      # Process error messages if they exist
      return contents
    end

    # Format text box question
    #
    def html_get_text(question)
      contents = ""
      # Get the user input if available
      if (@responses and !@responses.empty?() and 
        @responses.has_key?("#{question.code}"))
        user_answer = @responses["#{question.code}"]
        if (user_answer and !user_answer.blank?())
          contents += content_tag(:div, user_answer, :class => 'response_text')
        end
      end

      return contents
    end

    def html_get_textbox(question)
      contents = ""
      # Get the user input if available
      if (@responses and !@responses.empty?() and 
        @responses.has_key?("#{question.code}"))
        user_answer = @responses["#{question.code}"]
        if (user_answer and !user_answer.blank?())
          contents += content_tag(:div, user_answer, :class => 'response_text_box')
        end
      end

      return contents
    end

    # Format single choice question
    #
    def html_get_singlechoice(question)
      contents = ""
      question.answers.each do |answer|
        # Get the user input_objects if available
        if (@responses and !@responses.empty?() and 
          @responses.has_key?("#{question.code}"))
           if ( answer.answer ) 
             user_answer = @responses["#{question.code}"]
             if ((user_answer and !user_answer.blank?() and user_answer.to_s() == answer.code.to_s()))
             contents += content_tag(:div, answer.answer, :class => 'response_single_choice')
             end
          end
        end
        # Process any sub questions this answer may have
        contents += html_process_sub_questions(answer)
      end
      return contents
    end
 
    # Format drop down box(select) question
    #
    def html_get_selectionbox(question)
      contents = ""
      question.answers.each do |answer|
        # Get the user input if available
        if (@responses and !@responses.empty?() and 
          @responses.has_key?("#{question.code}") and
          @responses["#{question.code}"].include?("#{answer.code}"))
          contents += content_tag(:div, answer.answer, :class => 'response_selection')
        end
      end        
      
      return contents
    end

end
