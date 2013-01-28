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
        content += '<p>Publication Name: <em>' + fname + '</em></p>'
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
          contents += '<em>' + answer.answer + '</em>, '
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
          contents += '<em>' + user_answer + '</em> '
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
              contents += 'HHHHHH <em>' + answer.answer + '</em> '
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
          contents += '<em>' + answer.answer + '</em>'
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
      responses = respondent_detail.getResponsesForQuestion(question.survey_group.survey.id, question.id)
      if !responses.empty?
      content = "<h3>Availability</h3>\n"
      responses.each do |response|
        if response.response && response.response == '1'
          content += '<em>I am available for the complete duration of the Convention.</em><br/>'
        elsif response.response1
          content += 'From: <em>' + (Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + response.response1.to_i.day).strftime('%A, %B %e') + ' at ' + response.response2 + '</em><br/>'
          content += 'To: <em>' + (Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + response.response3.to_i.day).strftime('%A, %B %e') + ' at ' + response.response4 + '</em><br/>'
        elsif response.response5
          content += '<em>I am extremely uncertain when I will be available to be on the Program .</em><br/>'
        end
        content += "\n"
      end
      end
    when :address
      responses = respondent_detail.getResponsesForQuestion(question.survey_group.survey.id, question.id)
      if !responses.empty?
      content = '<h3>' + question.question + "</h3>\n"
      responses.each do |response|
        content += 'Street: <em>' + response.response + "</em><br/>\n"
        content += 'City: <em>' + response.response1 + "</em><br/>\n"
        content += 'State/County/Provence: <em>' + response.response2 + "</em><br/>\n"
        content += 'Postal Code/Zip: <em>' + response.response3 + "</em><br/>\n"
        content += 'Country: <em>' + response.response4 + "</em><br/>\n"
      end
      end
    when :phone
      responses = respondent_detail.getResponsesForQuestion(question.survey_group.survey.id, question.id)
      if !responses.empty?
      responses.each do |response|
        if  response.response &&  response.response1
          content += 'Phone: <em>' + response.response + ' (' + response.response1 + ')</em><br/>'
        end
      end
      end
    when :singlechoice
      responses = respondent_detail.getResponsesForQuestion(question.survey_group.survey.id, question.id)
      if !responses.empty?
        content = '<h3>' + question.question + "</h3>\n"
        responses.each do |response|
          # we have a number that needs to be converted
          content += '<em>' + SurveyAnswer.find(response.response.to_i).answer + "</em>&nbsp;\n"
        end
      end
    # when :selectionbox
      # responses = respondent_detail.getResponsesForQuestion(question.survey_group.survey.id, question.id)
      # if !responses.empty?
        # content = '<h3>' + question.question + '</h3>\n'
        # responses.each do |response|
          # content += response_to_html("HELP")
        # end
      # end
    when :textbox
      responses = respondent_detail.getResponsesForQuestion(question.survey_group.survey.id, question.id)
      if !responses.empty?
        content = '<h3>' + question.question + "</h3>\n"
        responses.each do |response|
          content += "<pre>" + response.response + "</pre>\n"
        end
      end
    else
      responses = respondent_detail.getResponsesForQuestion(question.survey_group.survey.id, question.id)
      if !responses.empty?
        content = '<h3>' + question.question + "</h3>\n"
        responses.each do |response|
          content += response_to_html(response)
        end
      end
    end

    return content
  end
  
  #
  #
  #
  def response_to_html(response)
    return '<em>' + response.response + "</em>&nbsp;\n"
  end
  
end
