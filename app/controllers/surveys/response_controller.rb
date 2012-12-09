#
# Render the survey
#
class Surveys::ResponseController < ApplicationController
  layout "dynasurvey"
  def create
    # We have the survey id and a set of responses, now we want to save it and associate it with a "person"
    @survey = Survey.find(params[:survey_id])
    @errors = Hash.new()

    # Get a collection of all the mandatory questions
    # Find the question id in the survey
    # check if it is mandatory
    # and then check that we have a response
    validate_responses(params, @errors)
    @survey_response = params[:survey_response]
    @survey_respondent_details = params[:survey_respondent_detail]

    if !@errors.empty?
      # render the page again with error messages
      render :index #", :page => "first"
    else
      # create the respondent details and link to the responses
      @responseDetails = SurveyRespondentDetail.new(params[:survey_respondent_detail])
      # make sure that we have a name and email address
      if @responseDetails.save
        params[:survey_response].each do |res|
        # check the type of the response and if an array then go though them
          if res[1].respond_to?('each')
            if res[1].is_a?(Hash)
             res[1].each do |r, v|
               response = SurveyResponse.new :survey_id => @survey.id, :survey_question_id => res[0], :response => v, :survey_respondent_detail => @responseDetails
               response.save
             end
           else
             res[1].each do |r|
               response = SurveyResponse.new :survey_id => @survey.id, :survey_question_id => res[0], :response => r, :survey_respondent_detail => @responseDetails
               response.save
             end
           end
          else
           response = SurveyResponse.new :survey_id => @survey.id, :survey_question_id => res[0], :response => res[1], :survey_respondent_detail => @responseDetails
           response.save
          end
        end
      else # re-show the original page
        render :index #", :page => "first"
      end
    end
  end

# TODO - we need an update mechanism for returning survey respondents


  # TODO - if there is a response for the particular user then we need to retrieve it and render the response...
  # This needs to be done via the respondent id (cookie or other if the person is logged in)
  def index
    if !@survey
      @survey = Survey.find(params[:survey_id])
      @page_title = @survey.name
      @errors = Hash.new()
    end
  end
  
  # Use a page alias for the survey and use it to render the survey to the potential respondent
  def renderalias
    page = params[:page] # use this to find the id of the survey from the database
    
    #find by alias
    if page
      @survey = Survey.find_by_alias(page)
      if @survey
        @page_title = @survey.name
        render :index
      end
    end
  end
  
  # TODO - need a preview and publish mechanism...
  
  # TODO - if there is a response for the particular user then we need to retrieve it and render the response...
  # This needs to be done via the respondent id (cookie or other if the person is logged in)
  # ALSO send confirmation of survey etc
private
  def validate_responses(params, errors)
    
    if params[:survey_respondent_detail]
      if params[:survey_respondent_detail]['last_name'].empty?
        errors['last_name'] = Hash.new if (errors['last_name'].nil?())
        errors['last_name']['Last Name'] = "Question requires an answer" 
      end
      if params[:survey_respondent_detail]['email'].empty?
        errors['email'] = Hash.new if (errors['email'].nil?())
        errors['email']['Email Address'] = "Question requires an answer" 
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

end

