class SurveyMailer < ActionMailer::Base

  #
  # Generic email mechanism, uses templates that have been defined in the database
  #  
  def email(recipient, mailuse, args)
    # get the mail parameters from the database
    config = MailConfig.first # it will be the first mail config anyway
    
    # get the template from the database that matches the specified use
    template = MailTemplate.first(:conditions => ["mail_use_id = ?",mailuse.id])
    
    
    # do parameter substitution for the body
    if args[:responses] != nil
      @responses = args[:responses].responses
    end
    content = ERB.new(template.content, 0, "%<>").result(binding) # pass in a context with the parameters i.e. ruby binding
    
    # then send the email
    recipients recipient #get_email(respondent)
    cc        config.cc
    from      config.from
    subject   template.subject # to get from the mail template
    sent_on   Time.now
    content_type "text/html"
    body      :title => template.title, :body => content
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
    
end
