#
#
#
module SurveyHtmlFormatter
  
  def getResponsesForQuestion(responses, surveyId, questionId)
    responses.collect { |x| (x.survey_id == surveyId && x.survey_question_id == questionId) ? x : nil }.compact
  end
  
  #
  # For a given survey produce an HTML version of the questions and answers
  #
  def survey_to_html(survey, respondent_detail, forEmail = true)
    if survey
      content = '<div class="survey_responses"><h1>' + survey.name + '</h1>'
      content += "\n" if forEmail
      responses = respondent_detail.getResponses(survey.id)
      
      if respondent_detail.survey_respondent
        person = respondent_detail.survey_respondent.person
        if person
          fname = person.getFullPublicationName()
          content += '<h3 class="response_group_header">Publication Name:</h3><div class="response_group_body"><div class="response_answer"><div class="response_text">' + fname + '</div></div></div>'
          content += "\n" if forEmail
        end
      else
        fname = respondent_detail.getFullName()
        if ! fname.blank?
          content += '<h3 class="response_group_header">Name:</h3><div class="response_group_body"><div class="response_answer"><div class="response_text">' + fname + '</div></div></div>'
          content += "\n" if forEmail
        end
        if ! respondent_detail.email.blank?
          content += '<h3 class="response_group_header">Email:</h3><div class="response_group_body"><div class="response_answer"><div class="response_text">' + respondent_detail.email + '</div></div></div>'
          content += "\n" if forEmail
        end
      end
      
      survey.survey_groups.each do |group|
        content += group_to_html(group, respondent_detail, forEmail, responses)
      end
      
      content += '</div>'
      content += "\n" if forEmail
    else
      content = '<div>No Survey Found</div>'
    end
    return content
  end
  
  #
  #
  #
  def group_to_html(group, respondent_detail, forEmail, responses)
    content = '<h3 class="response_group_header">' + group.name + '</h2><div class="response_group_body">'
    
    group.survey_questions.each do |question|
      if getResponsesForQuestion(responses, group.survey.id, question.id) #respondent_detail.hasResponsesForQuestion(group.survey.id, question.id)
        content += question_to_html(question, respondent_detail, forEmail, responses)
      end
    end
    
    content += "</div>"
    content += "\n" if forEmail
    
    return content
  end

  
  private
  
  def question_to_html(question, respondent_detail, forEmail, responses)
    content = ''
    
    if (!question.private || (!forEmail && question.private && (permitted_to? :supermanage, :surveys)))
      case question.question_type
      when :availability
        content += availabilty_to_html(question, respondent_detail, forEmail, responses)
      when :address
        content += address_to_html(question, respondent_detail, forEmail, responses)
      when :phone
        content += phone_to_html(question, respondent_detail, forEmail, responses)
      when :singlechoice
        content += single_choice_to_html(question, respondent_detail, forEmail, responses)
      when :textbox
        content += textbox_to_html(question, respondent_detail, forEmail, responses)
      when :photo
        content += photo_to_html(question, respondent_detail, forEmail, responses)
      else
        content += text_to_html(question, respondent_detail, forEmail, responses)
      end
    end
    
    return content    
  end
  
  def photo_to_html(question, respondent_detail, forEmail, responses)
    content = '<div class="response_answer">'

    responses = getResponsesForQuestion(responses, question.survey_group.survey.id, question.id)
    if !responses.empty? && !responses[0].response.blank?

      content += '<div class="response_question_text"'
      content += 'style="font-weight: bold; padding-right: 1em;"' if forEmail
      content += '><strong>' + question.question + "</strong></div>"

      responses.each do |response|
        if response.photo && response.photo.url
          content += '<div class="response_answer">'
          content += '<div class="response_photo"><image src="' + response.photo.url + '" width="250"></div>'
          content += '</div>'
          content += "\n" if forEmail
        end
      end
      
    end

    content += '</div>'
    content += "\n" if forEmail
    return content
  end

  def text_to_html(question, respondent_detail, forEmail, responses)
    content = '<div class="response_answer">'
    responses = getResponsesForQuestion(responses, question.survey_group.survey.id, question.id)
    if !responses.empty? && !responses[0].response.blank?
      content += '<div class="response_question_text"'
      content += 'style="font-weight: bold; padding-right: 1em;"' if forEmail
      content += '><strong>' + question.question + "</strong></div><pre>"
      responses.each do |response|
        content += '<div class="response_answer">'
        content += '<div class="response_text">' + response.response + "</div>"
        content += '</div>'
        content += "\n" if forEmail
      end
    end
    content += '</pre></div>'
    content += "\n" if forEmail
    return content
  end
  
  def textbox_to_html(question, respondent_detail, forEmail, responses)
    content = '<div class="response_answer">'
    responses = getResponsesForQuestion(responses, question.survey_group.survey.id, question.id)
    if !responses.empty? && !responses[0].response.blank?
      content += '<div class="response_question_text"'
      content += 'style="font-weight: bold; padding-right: 1em;"' if forEmail
      content += '><strong>' + question.question + "</strong></div>"
      content += "\n" if forEmail
      responses.each do |response|
        content += '<div class="response_answer">'
        content += '<div class="response_text_box"><pre>' 
        content += "\n" if forEmail
        # NOTE: there is a 1000 character line limit so need to split close to 900 to be safe and insert a new line
        content += "<pre>\n" if forEmail
        if forEmail
          # split on white space and keep a count
          count = 0
          response.response.each_line(' ') { |s|
            if count > 900
              content += "\n"
              count = 0
            end
            content += s
            count += s.size + 1
          }
        else  
          content += response.response 
        end
        content += "\n</pre>" if forEmail
        content += "\n" if forEmail
        content += '</pre></div></div>'
        content += "\n" if forEmail
      end
    end
    content += '</div>'
    content += "\n" if forEmail
    return content
  end
  
  def single_choice_to_html(question, respondent_detail, forEmail, responses)
    content = '<div class="response_answer">'
    responses = getResponsesForQuestion(responses, question.survey_group.survey.id, question.id)
    if !responses.empty? && !responses[0].response.blank?
      content += '<div class="response_question_text"'
      content += 'style="font-weight: bold; padding-right: 1em;"' if forEmail
      content += '><strong>' + question.question + "</strong></div>"
      content += "\n" if forEmail
      responses.each do |response|
        content += '<div class="response_answer">'
        content += '<div class="response_text"><pre>' + response.response + "</pre></div>"
        content += '</div>'
        content += "\n" if forEmail
      end
    end
    content += '</div>'
    content += "\n" if forEmail
    return content
  end
  
  def phone_to_html(question, respondent_detail, forEmail, responses)
    content = '<div class="response_answer">'
    responses = getResponsesForQuestion(responses, question.survey_group.survey.id, question.id)
    if !responses.empty? && !responses[0].response.blank?
      responses.each do |response|
        content += '<div class="response_answer">'
        content += '<div class="response_question_text" '
        content += 'style="font-weight: bold; padding-right: 1em;"' if forEmail
        content += '><strong>Phone</strong></div><div class="response_answer"><div class="response_text"><pre>' + response.response 
        content += ' (' + response.response1 + ')' if response.response1
        content += "</pre></div></div>"
        content += '</div>'
        content += "\n" if forEmail
      end
    end
    content += '</div>'
    content += "\n" if forEmail
    return content
  end
  
  def address_to_html(question, respondent_detail, forEmail, responses)
    content = '<div class="response_answer">'
    
    
    responses = getResponsesForQuestion(responses, question.survey_group.survey.id, question.id) 
    if !responses.empty?
      responses.each do |response|
        content += '<div class="response_answer">'
        content += '<div class="response_question_text" '
        content += 'style="font-weight: bold; padding-right: 1em;"' if forEmail
        content += '><strong>Street Address</strong></div><div class="response_answer"><div class="response_text"><pre>' + response.response + "</pre></div></div>"
        content += "\n" if forEmail
        content += '<div class="response_question_text" '
        content += 'style="font-weight: bold; padding-right: 1em;"' if forEmail
        content += '><strong>City</strong></div><div class="response_answer"><div class="response_text"><pre>' + response.response1 + "</pre></div></div>"
        content += "\n" if forEmail
        content += '<div class="response_question_text" '
        content += 'style="font-weight: bold; padding-right: 1em;"' if forEmail
        content += '><strong>State/County/Provence</strong></div><div class="response_answer"><div class="response_text"><pre>' + response.response2 + "</pre></div></div>"
        content += "\n" if forEmail
        content += '<div class="response_question_text" '
        content += 'style="font-weight: bold; padding-right: 1em;"' if forEmail
        content += '><strong>Postal Code/Zip</strong></div><div class="response_answer"><div class="response_text"><pre>' + response.response3 + "</pre></div></div>"
        content += "\n" if forEmail
        content += '<div class="response_question_text" '
        content += 'style="font-weight: bold; padding-right: 1em;"' if forEmail
        content += '><strong>Country</strong></div><div class="response_answer"><div class="response_text"><pre>' + response.response4 + "</pre></div></div>"
        content += '</div>'
        content += "\n" if forEmail
      end
    end

    content += '</div>'
    content += "\n" if forEmail
    return content
  end
  
  def availabilty_to_html(question, respondent_detail, forEmail, responses)
    content = '<div class="response_answer">'
    
    responses = getResponsesForQuestion(responses, question.survey_group.survey.id, question.id) 

    responses.each do |response|
      if response.response && response.response == '1'
        content += '<div class="response_answer"><pre>I am available for the complete duration of the Convention.</pre></div>'
      elsif response.response1
        content += '<div class="response_answer"><pre>'
        if SiteConfig.first
          content += 'From: <em>' + (Time.zone.parse(SiteConfig.first.start_date.to_s) + response.response1.to_i.day).strftime('%A, %B %e') + ' at ' + response.response2 + '</em><br/>'
          content += 'To: <em>' + (Time.zone.parse(SiteConfig.first.start_date.to_s) + response.response3.to_i.day).strftime('%A, %B %e') + ' at ' + response.response4 + '</em><br/>'
        end
          content += '</pre></div>'
      elsif response.response5
        content += '<div class="response_answer"><pre>I am extremely uncertain when I will be available to be on the Program.</pre></div>'
      end
      
    end
    
    content += '</div>'
    content += "\n" if forEmail
    return content
  end
    
end
