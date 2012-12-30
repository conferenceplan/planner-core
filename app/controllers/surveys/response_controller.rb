#
# Render the survey
#
class Surveys::ResponseController < SurveyApplicationController
  layout "dynasurvey"

  before_filter :check_for_single_access_token, :only => [:create, :show, :index, :renderalias]
  
  #
  #
  #
  def create
    init()
    
    if !@errors.empty?
      # render the page again with error messages
      @current_key = params[:key];
      render :index #", :page => "first"
    else # TODO - put this within a transaction...
      if @respondent && @respondent.survey_respondent_detail
        respondentDetails = @respondent.survey_respondent_detail
        responses = @respondent.survey_respondent_detail.getResponses(@survey.id)
      else
        # save the details and add to the respondent
        # create the respondent details and link to the responses
        respondentDetails = SurveyRespondentDetail.new(params[:survey_respondent_detail]) 
        if respondentDetails.save
          if @respondent
            @respondent.survey_respondent_detail = respondentDetails
            @respondent.save
          end
        end
      end

      # make sure that we have a name and email address
      params[:survey_response].each do |res|
        # check the type of the response and if an array then go though them
        if res[1].respond_to?('each')
          if res[1].is_a?(Hash)
           res[1].each do |r, v|
             response = respondentDetails.getResponse(@survey.id, res[0])
             if response != nil
               response.response = v
             else
               response = SurveyResponse.new :survey_id => @survey.id, :survey_question_id => res[0], :response => v, :survey_respondent_detail => respondentDetails
             end
             response.save
           end
          else
           res[1].each do |r|
             response = respondentDetails.getResponse(@survey.id, res[0])
             if response != nil
               response.response = r
             else
               response = SurveyResponse.new :survey_id => @survey.id, :survey_question_id => res[0], :response => r, :survey_respondent_detail => respondentDetails
             end
             response.save
           end
          end
        else
          response = respondentDetails.getResponse(@survey.id, res[0])
          if response != nil
            response.response = res[1]
          else
            response = SurveyResponse.new :survey_id => @survey.id, :survey_question_id => res[0], :response => res[1], :survey_respondent_detail => respondentDetails
          end
          response.save
        end
      end
    end
  end
  # TODO: send email confirmation of survey etc


  # This needs to be done via the respondent id (cookie or other if the person is logged in)
  # TODO - if there is a response for the particular user then we need to retrieve it and render the response...
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
    
    #find by alias
    if page
      @survey = Survey.find_by_alias(page)
      if @survey
        @page_title = @survey.name
        @current_key = params[:key]
        @path = '/surveys/' + @survey.id.to_s + '/response'
        if (@respondent && @respondent.survey_respondent_detail && @respondent.survey_respondent_detail.hasResponses(@survey.id))
          @survey_response = convertInputArray(@respondent.survey_respondent_detail)
          @survey_respondent_details = getSurveyResponseDetails(@respondent.survey_respondent_detail)
        end
       render :index
      end
    end
  end
  
private
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
    @survey_respondent_details = params[:survey_respondent_detail]
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
  
  #
  #
  #
  def convertInputArray(details) # arg os SurveyRespondentDetail, need the questions!!
    res = {}
    
    details.survey_responses.each do |response|
      if response.survey_question.question_type == :multiplechoice # then we need to add a hash
        # if it is a multi-choice then a hash and need to look up the ids of the 'answers'
        if !res[response.survey_question_id.to_s]
          res[response.survey_question_id.to_s] = {}
        end
        idx = response.survey_question.survey_answers.index{|x| x.answer == response.response }
        if !res[response.survey_question_id.to_s]
          res[response.survey_question_id.to_s] = {}
        end
        res[response.survey_question_id.to_s][response.survey_question.survey_answers[idx].id.to_s] = response.response.to_s # TODO - ERROR
      else  
        res[response.survey_question_id.to_s] = response.response.to_s
      end
    end
   
    return res   
  end

  #
  #
  #  
  def getSurveyResponseDetails(details) 
    res = {}
    
    res['first_name'] = details.first_name  if details.first_name
    res['last_name'] = details.last_name  if details.last_name
    res['suffix'] = details.suffix if details.suffix
    res['email'] = details.email if details.email
    
    return res
  end

end

