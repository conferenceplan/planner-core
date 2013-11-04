#
# Render the survey
#
class Surveys::ResponseController < ApplicationController
  layout "dynasurvey"

  before_filter :check_for_single_access_token, :only => [:create, :show, :index, :renderalias]
  #
  #
  #
  def create
    @site_config = SiteConfig.first

    init()
    if @survey.use_captcha
      if (!verify_recaptcha :private_key => @site_config.captcha_priv_key)
        @errors['captcha'] = { "captcha" => "There is a problem with your answer to the CAPTCHA!" }
      end
    end

    if !@errors.empty?
      # render the page again with error messages
      @current_key = params[:key];
      render :index
    else
      respondentDetails = nil
      
      begin
        SurveyRespondentDetail.transaction do
          p = params[:survey_respondent_detail].reject {|x| ['pub_first_name', 'pub_last_name', 'pub_suffix'].include? x }
          if @respondent && @respondent.survey_respondent_detail
            respondentDetails = @respondent.survey_respondent_detail
            respondentDetails.update_attributes(p)
            respondentDetails.save!
            responses = @respondent.survey_respondent_detail.getResponses(@survey.id)
          else
            # save the details and add to the respondent, create the respondent details and link to the responses
            respondentDetails = SurveyRespondentDetail.new(p)
            respondentDetails.save!
            if @respondent
              # and assign the details to the respondent
              @respondent.survey_respondent_detail = respondentDetails
              @respondent.save!
            end
          end
          
          # # also update the underlying person
          updatePerson(@respondent, params[:survey_respondent_detail]) if @respondent

          # TODO - we need to clear out reponses that have missing answers... i.e. go through the questions and delete the responses for ones that do not have answers
          # make sure that we have a name and email address
          params[:survey_response].each do |res|
          # check the type of the response and if an array then go though them
            if res[1].respond_to?('each')
              if res[1].is_a?(Hash)

                responses = respondentDetails.getResponsesForQuestion(@survey.id, res[0])
                responses.each do |r|
                  r.delete
                end

                surveyQuestion = SurveyQuestion.find(res[0])
                if surveyQuestion.question_type == :address
                  saveAddress(res[1], @survey, res[0], respondentDetails)
                elsif surveyQuestion.question_type == :availability
                  saveAvailability(res[1], @survey, res[0], respondentDetails)
                elsif surveyQuestion.question_type == :phone
                  savePhone(res[1], @survey, res[0], respondentDetails)
                else  
                  res[1].each do |r, v|
                    response = SurveyResponse.new :survey_id => @survey.id, :survey_question_id => res[0], :response => v, :survey_respondent_detail => respondentDetails
                    response.isbio = surveyQuestion.isbio
                    response.save!
                  end
                end
              else
                if res[1].empty?
                  saveResponse(@respondent, @survey, res[0], '', respondentDetails)
                else
                  saveResponse(@respondent, @survey, res[0], res[1].to_s, respondentDetails)
                end
              end
            else
              saveResponse(@respondent, @survey, res[0], res[1], respondentDetails)
            end
          end
        end
        # roll back the transaction if there is an issue
      rescue Exception => err
        logger.error "We were unable to save the survey"
        logger.error err
        logger.error err.backtrace
        @current_key = params[:key];
        render :index
      end
      
      # send email confirmation of survey etc., use the email address that they provided in the survey
      begin
        if @respondent
          SurveyMailer.email(@respondent.email, MailUse[:CompletedSurvey], @survey.id, {
            :email => @respondent.email,
            :user => @respondent,
            :survey => @survey,
            :respondentDetails => @respondent.survey_respondent_detail
          }).deliver
        elsif respondentDetails
          SurveyMailer.email(respondentDetails.email, MailUse[:CompletedSurvey], @survey.id, {
            :email => respondentDetails.email,
            :user => respondentDetails, # TODO - check that this will work
            :survey => @survey,
            :respondentDetails => respondentDetails
          }).deliver
        end
      rescue Exception => err
        logger.error "Unable to send the email to " + @respondent.email if @respondent
        logger.error "Unable to send the email to " + respondentDetails.email if !@respondent
        logger.error err
        logger.error err.backtrace
      end
      
    end
  end
  
  # This needs to be done via the respondent id (cookie or other if the person is logged in)
  def index
    if !@survey
      @survey = Survey.find(params[:survey_id])
      @page_title = @survey.name
      @errors = Hash.new()
    end
  end

  #
  # Use a page alias for the survey and use it to render the survey to the potential respondent
  #
  def renderalias
    page = params[:page] # use this to find the id of the survey from the database
    @preview = params[:preview] == 'preview'
    @site_config = SiteConfig.first

    if page
      
      # TODO - check if this is preview, if so do a render (but disable the save on submit)
      # if not a preview then check if authentication is needed, it it is then ask for authentication before rendering the form
      
      # find the survey for the page alias
      @survey = Survey.find_by_alias(page)
      if @survey && (@survey.public || @preview)
        
        # return unless @survey.public || @preview
        
        if  !@preview && @survey.authenticate # TODO *****
          # check to see if the use is authenticated
          # require_user # TODO - change to test for single access token etc.
          if !user_logged_in?
            logger.error "NEED TO LOGIN"
            store_location
            redirect_to new_user_session_url
          end
        end
        
        @page_title = @survey.name
        @current_key = params[:key]
        @path = '/surveys/' + @survey.id.to_s + '/response' # TODO - fix for language...

        if @respondent && !preview
          if @respondent.survey_respondent_detail
            @survey_respondent_detail = getSurveyResponseDetails(@respondent.survey_respondent_detail, @respondent.person)

            if @respondent.survey_respondent_detail.hasResponses(@survey.id)
              @survey_response = convertInputArray(@respondent.survey_respondent_detail, @respondent.person)
            else
              @survey_response = convertInitialInputArray(@survey, @respondent.person)
            end
          else
            # if we have a respondent and empty details then we want to pre-populate the details
            @respondent.survey_respondent_detail = SurveyRespondentDetail.new( {:email => @respondent.email, :first_name => @respondent.first_name, :last_name => @respondent.last_name, :suffix => @respondent.suffix})
            @respondent.survey_respondent_detail.save
            @survey_respondent_detail = getSurveyResponseDetails(@respondent.survey_respondent_detail, @respondent.person)
              @survey_response = convertInitialInputArray(@survey, @respondent.person)
          end
        end
      else
        @survey = nil
      end
    end
  end

  private
  
  def saveAvailability(values, survey, questionId, respondentDetails)
    response = respondentDetails.getResponse(survey.id, questionId)
    if response != nil
      response.response = values['response']
      response.response1 = values['response1']
      response.response2 = values['response2']
      response.response3 = values['response3']
      response.response4 = values['response4']
      response.response5 = values['response5']
    else
      response = SurveyResponse.new :survey_id => survey.id, :survey_question_id => questionId, 
        :response => values['response'], 
        :response1 => values['response1'], 
        :response2 => values['response2'], 
        :response3 => values['response3'], 
        :response4 => values['response4'], 
        :response5 => values['response5'], 
        :survey_respondent_detail => respondentDetails
    end
    response.save!
  end
  
  def savePhone(values, survey, questionId, respondentDetails)
    response = respondentDetails.getResponse(survey.id, questionId)
    if response != nil
      response.response = values['response']
      response.response1 = values['response1']
    else
      response = SurveyResponse.new :survey_id => survey.id, :survey_question_id => questionId, 
        :response => values['response'], 
        :response1 => values['response1'], 
        :survey_respondent_detail => respondentDetails
    end
    
    # If we have an actual respondent then we can update their address
    # street, city, state, zip
    if @respondent
      # get the underlying person
      person = @respondent.person
      # update their default address if this is not already the default address
      if response.response && response.response1
        person.updatePhone(response.response, response.response1)
      end
    end
    
    response.save!
  end

  
  def saveAddress(values, survey, questionId, respondentDetails)
    response = respondentDetails.getResponse(survey.id, questionId)
    if response != nil
      response.response = values['response']
      response.response1 = values['response1']
      response.response2 = values['response2']
      response.response3 = values['response3']
      response.response4 = values['response4']
    else
      response = SurveyResponse.new :survey_id => survey.id, :survey_question_id => questionId, 
        :response => values['response'], 
        :response1 => values['response1'], 
        :response2 => values['response2'], 
        :response3 => values['response3'], 
        :response4 => values['response4'], 
        :survey_respondent_detail => respondentDetails
    end
    
    # If we have an actual respondent then we can update their address
    # street, city, state, zip
    if @respondent
      # get the underlying person
      person = @respondent.person
      # update their default address if this is not already the default address
      if !person.addressMatch?(response.response, response.response1, response.response2, response.response3, response.response4)
        person.updateDefaultAddress(response.response, response.response1, response.response2, response.response3, response.response4)
      end
    end
    
    response.save!
  end
  
  def saveResponse(surveyRespondent, survey, questionId, responseText, respondentDetails)
    surveyQuestion = SurveyQuestion.find(questionId)
    response = nil
    
    if !surveyQuestion.tags_label.empty? && surveyQuestion.question_type == :textfield
      responseText = responseText.split(' ').map {|w|
        w[0] = w[0].chr.upcase
        w }.join(' ')
    end
    
    response = respondentDetails.getResponse(survey.id, questionId)
    if response != nil
      response.response = responseText
    else
      response = SurveyResponse.new :survey_id => survey.id, :survey_question_id => questionId, :response => responseText, :survey_respondent_detail => respondentDetails
    end
    
    response.isbio = surveyQuestion.isbio

    saveTags(surveyRespondent, responseText, surveyQuestion.tags_label) if (!surveyQuestion.tags_label.empty? && surveyQuestion.question_type == :textfield) if surveyRespondent

    response.save!
  end
 
  #
  #
  # set the tag list on the respondent for the context
  #
  def saveTags(respondent, responseText, context)
    respondent.set_tag_list_on(context, responseText)
    respondent.save!
    
    # attach tags to the underlying person as well
    person = respondent.person
    if person
      person.set_tag_list_on(context, responseText)
      person.save!
    end
  end
  
  #
  #
  #
  def updatePerson(respondent, respondentParams)
    person = respondent.person
    # details = respondent
    if person
      # then update it with the various details
      # email
      detail = respondent.survey_respondent_detail
      # add email to person
      if !person.emailMatch?(detail.email)
        person.updateDefaultEmail(detail.email)
      end
      
      # Now do Publication Name
      if !respondentParams['pub_first_name'].blank? || !respondentParams['pub_last_name'].blank? || !respondentParams['pub_suffix'].blank?
        if !person.pseudonym
          person.pseudonym = Pseudonym.new :first_name => respondentParams['pub_first_name'], :last_name => respondentParams['pub_last_name'], :suffix => respondentParams['pub_suffix'] 
        else
          person.pseudonym.first_name = respondentParams['pub_first_name']
          person.pseudonym.last_name = respondentParams['pub_last_name']
          person.pseudonym.suffix = respondentParams['pub_suffix']
        end
        
        person.pseudonym.save!
      else
        if person.pseudonym
          person.pseudonym.delete
        end
      end
      
      person.first_name = detail.first_name if detail.first_name
      person.last_name = detail.last_name if detail.last_name
      person.suffix = detail.suffix if detail.suffix
      
      person.acceptance_status = AcceptanceStatus[:Accepted]
      
      #
      # respondent.save!
      person.save!
    end
  end
  
  #
  #
  #
  def init
    # We have the survey id and a set of responses, now we want to save it and associate it with a "person"
    @survey = Survey.find(params[:survey_id])
    @errors = Hash.new()

    # Get a collection of all the mandatory questions
    # Find the question id in the survey
    # check if it is mandatory
    # and then check that we have a response
    validate_responses(params, @errors)
    @survey_response = params[:survey_response]
    @survey_respondent_detail = params[:survey_respondent_detail]
  end

  #
  #
  #
  def validate_responses(params, errors)

    if params[:survey_respondent_detail]
      if params[:survey_respondent_detail]['last_name'].empty?
        errors['last_name'] = Hash.new if (errors['last_name'].nil?())
        errors['last_name']['Last Name'] = "Question requires an answer"
      end
      if params[:survey_respondent_detail]['email'].empty?
        errors['email'] = Hash.new if (errors['email'].nil?())
        errors['email']['Email Address'] = "requires an answer"
      elsif params[:survey_respondent_detail]['email'].index(/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/) == nil
        errors['email'] = Hash.new if (errors['email'].nil?())
        errors['email']['Email Address'] = "format is incorrect"
      end #email_address
    end

    allQuestions = @survey.getAllQuestions # get all the questions related to this survey

    allQuestions.each do |question|
      if question.mandatory
        # check to see if we have a response
        if !params[:survey_response] || !params[:survey_response][question.id.to_s] || params[:survey_response][question.id.to_s].empty?
          errors[question.id] = Hash.new if (errors[question.id].nil?())
          errors[question.id][question.question] = "Question requires an answer"
        end
      end
    end
  end

  #
  #
  #
  def convertInputArray(details, person) # arg os SurveyRespondentDetail, need the questions!!
    res = {}
    if details && details.survey_responses
    details.survey_responses.each do |response|
      if response.survey_question && response.survey_question.question_type == :multiplechoice
        # then we need to add a hash
        # if it is a multi-choice then a hash and need to look up the ids of the 'answers'
        if !res[response.survey_question_id.to_s]
          res[response.survey_question_id.to_s] = {}
        end
        idx = response.survey_question.survey_answers.index{|x| x.answer == response.response }
        # if !res[response.survey_question_id.to_s]
          # res[response.survey_question_id.to_s] = {}
        # end
        res[response.survey_question_id.to_s][response.survey_question.survey_answers[idx].id.to_s] = response.response.to_s
      elsif response.survey_question && response.survey_question.question_type == :availability
        if !res[response.survey_question_id.to_s]
          res[response.survey_question_id.to_s] = {}
        end
        res[response.survey_question_id.to_s]['response'] = response.response
        res[response.survey_question_id.to_s]['response1'] = response.response1
        res[response.survey_question_id.to_s]['response2'] = response.response2
        res[response.survey_question_id.to_s]['response3'] = response.response3
        res[response.survey_question_id.to_s]['response4'] = response.response4
        res[response.survey_question_id.to_s]['response5'] = response.response5
      elsif response.survey_question && response.survey_question.question_type == :phone
        if !res[response.survey_question_id.to_s]
          res[response.survey_question_id.to_s] = {}
        end
        res[response.survey_question_id.to_s]['response'] = response.response
        res[response.survey_question_id.to_s]['response1'] = response.response1
      elsif response.survey_question && response.survey_question.question_type == :address
        if !res[response.survey_question_id.to_s]
          res[response.survey_question_id.to_s] = {}
        end
        if person
          address = person.getDefaultPostalAddress()
          res[response.survey_question_id.to_s]['response'] = address.line1
          res[response.survey_question_id.to_s]['response1'] = address.city
          res[response.survey_question_id.to_s]['response2'] = address.state
          res[response.survey_question_id.to_s]['response3'] = address.postcode
          res[response.survey_question_id.to_s]['response4'] = address.country
        else  
          res[response.survey_question_id.to_s]['response'] = response.response
          res[response.survey_question_id.to_s]['response1'] = response.response1
          res[response.survey_question_id.to_s]['response2'] = response.response2
          res[response.survey_question_id.to_s]['response3'] = response.response3
          res[response.survey_question_id.to_s]['response4'] = response.response4
        end
      else
        res[response.survey_question_id.to_s] = response.response.to_s
      end
    end
    end
    return res
  end
  
  def convertInitialInputArray(survey, person)
    res = {}

    if person
      address = person.getDefaultPostalAddress()
      
      if address
        # find all questions in this survey that are of type address
        results = SurveyQuestion.all(
          :conditions => ['survey_groups.survey_id = ? AND question_type = ?', survey.id, 'address'],
          :include => [:survey_group]
        )
        
        if results.respond_to?('each')
          results.each do |q|
            if !res[q.id.to_s]
              res[q.id.to_s] = {}
            end
            res[q.id.to_s]['response'] = address.line1
            res[q.id.to_s]['response1'] = address.city
            res[q.id.to_s]['response2'] = address.state
            res[q.id.to_s]['response3'] = address.postcode
            res[q.id.to_s]['response4'] = address.country
          end
        else
          res[results.id.to_s] = {}
          res[results.id.to_s]['response'] = address.line1
          res[results.id.to_s]['response1'] = address.city
          res[results.id.to_s]['response2'] = address.state
          res[results.id.to_s]['response3'] = address.postcode
          res[results.id.to_s]['response4'] = address.country
        end
      end
      
    end
    
    return res
  end
  
  #
  #
  #
  def getSurveyResponseDetails(details, person)
    res = {}

    if person
      res['first_name'] = person.first_name
      res['last_name'] = person.last_name
      res['suffix'] = person.suffix
      res['email'] = person.getDefaultEmail().email
    else  
      res['first_name'] = details.first_name  if details.first_name
      res['last_name'] = details.last_name  if details.last_name
      res['suffix'] = details.suffix if details.suffix
      res['email'] = details.email if details.email
    end
    
    # if we have a pseudonym then use it
    if person && person.pseudonym
      res['pub_first_name'] = person.pseudonym.first_name  if person.pseudonym.first_name
      res['pub_last_name'] = person.pseudonym.last_name  if person.pseudonym.last_name
      res['pub_suffix'] = person.pseudonym.suffix if person.pseudonym.suffix
    end

    return res
  end

end

