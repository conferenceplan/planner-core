#
#
#
module SurveyHtmlFormatter
  
  #
  # For a given survey produce an HTML version of the questions and answers
  #
  def survey_to_html(survey, respondent_detail)
    content = '<h1>' + survey.name + '</h1>'
    
    # Need to add information about the name, pub name, and addres of the participant - TODO
    if respondent_detail.survey_respondent
      person = respondent_detail.survey_respondent.person
      if person
        fname = person.GetFullPublicationName()
        content += '<p>Publication Name: <b>' + fname + '</b></p>'
      end      
    end
    
    survey.survey_groups.each do |group|
      
      content += group_to_html(group, respondent_detail)
      
    end
    
    return content
  end
  
  #
  #
  #
  def group_to_html(group, respondent_detail)
    content = '<h2>' + group.name + '</h2>'
    
    group.survey_questions.each do |question|
      if respondent_detail.hasResponsesForQuestion(group.survey.id, question.id)
        content += question_to_html(question, respondent_detail)
        logger.debug content
      end
    end
    
    return content
  end

  # --------------------------
  # This is a temporary fix while sites are using SMERF
  #
  def format_group(group)
    content = ''
    question_content = ''
    
    group.questions.each do |question|
      begin
        question_content += smerf_html_group_question(question)
      rescue => msg
        logger.error msg #+ ": in question: " + question
      end
    end
    
    if (!question_content.blank?)
      content += '<h3>' + group.name + '</h3>' if !group.name.blank?
      content += question_content
    end
    
    return content
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
      answer += get_textbox(question)
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
        content += question.question + ' '
      end
      content += answer;
      content += '<br/>'
    end

    if question.additional
      # for each of the additional we want to create a new version of the same question
      1.upto(question.additional) { |i|
        dup_question = question.clone
        dup_question.additional = 0
        dup_question.code += "-" + i.to_s
        change_question_code(dup_question, "-" + i.to_s)
        # need to go through the nested questions and change their codes as well
        content += smerf_html_group_question(dup_question)        
     }
    end
    
    return content
  end
  
  private
    def change_question_code(question, code)
      question.answers.each do |answer|
        if (answer.respond_to?("subquestions") and answer.subquestions and answer.subquestions.size > 0)
        answer.subquestions.each {|subquestion| 
           subquestion.code += code
           change_question_code(subquestion, code)
          }
        end
      end
    end

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
          contents += '<b>' + answer.answer + '</b>, '
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
          contents += '<b>' + user_answer + '</b> '
        end
      end

      return contents
    end

    def get_textbox(question)
      contents = ""
      # Get the user input if available
      if (@responses and !@responses.empty?() and 
        @responses.has_key?("#{question.code}"))
        user_answer = @responses["#{question.code}"]
        if (user_answer and !user_answer.blank?())
          contents += '<pre>' + user_answer + '</pre> '
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
             contents += '<b>' + answer.answer + '</b> '
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
          contents += '<b>' + answer.answer + '</b>'
        end
      end        
      
      return contents
    end

  #
  #
  #
  def question_to_html(question, respondent_detail)
    content = ''
    
    case question.question_type
    when :availability
      content = '<h3>Availability</h3>'
      responses = respondent_detail.getResponsesForQuestion(question.survey_group.survey.id, question.id)
      responses.each do |response|
        if response.response && response.response == '1'
          content += '<b>I am available for the complete duration of the Convention.</b>'
        elsif response.response1
          content += 'From: <b>' + (Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + response.response1.to_i.day).strftime('%A, %B %e') + ' at ' + response.response2 + '</b><br/>'
          content += 'To: <b>' + (Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + response.response3.to_i.day).strftime('%A, %B %e') + ' at ' + response.response4 + '</b>'
        elsif response.response5
          content += '<b>I am extremely uncertain when I will be available to be on the Program .</b>'
        end
      end
    when :address
      content = '<h3>' + question.question + '</h3>'
      responses = respondent_detail.getResponsesForQuestion(question.survey_group.survey.id, question.id)
      responses.each do |response|
        content += 'Street: <b>' + response.response + '</b><br/>'
        content += 'City: <b>' + response.response1 + '</b><br/>'
        content += 'State/County/Provence: <b>' + response.response2 + '</b><br/>'
        content += 'Postal Code/Zip: <b>' + response.response3 + '</b><br/>'
        content += 'Country: <b>' + response.response4 + '</b><br/>'
      end
    when :phone
      responses = respondent_detail.getResponsesForQuestion(question.survey_group.survey.id, question.id)
      responses.each do |response|
        if  response.response &&  response.response1
          content += 'Phone: <b>' + response.response + ' (' + response.response1 + ')</b><br/>'
        end
      end
    else
      content = '<h3>' + question.question + '</h3>'
      responses = respondent_detail.getResponsesForQuestion(question.survey_group.survey.id, question.id)
      responses.each do |response|
        content += response_to_html(response)
      end
    end

    return content
  end
  
  #
  #
  #
  def response_to_html(response)
    return '<b>' + response.response + '</b>'
  end
  
end
