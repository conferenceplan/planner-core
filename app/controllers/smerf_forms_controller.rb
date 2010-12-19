# This controller contains methods that displays the smerf form, allows
# the user to answer or edit responses on the form. The controller has
# been developed using REST and responds to the following requests:
#
# * GET /smerf_forms/smerf_form_file_name - displays specified smerf form
# * POST /smerf_forms - creates a new record to save responses
# * PUT /smerf_form/1 - updates existing record with responses
#

class SmerfFormsController < SurveyApplicationController

  before_filter :check_for_single_access_token, :only => [:create, :show, :update]

  include Smerf
  
  layout "survey"

  # GET /smerf_forms/smerf_form_file_name
  # 
  # <tt>where smerf_form_file_name = the name of the smerf form definition file to load and process</tt>
  # 
  # This method displays the specified form using the name of the smerf form 
  # definition file to identify which form to display. If this is the first 
  # time the form is being displayed the form definition file will be read,
  # processed and the results stored in the survay DB table. Subsequently the 
  # form will be retrieved directly from the DB.
  # 
  # If the form definition file is modified then the form data in the DB will 
  # be rebuilt from the form definition file. Smerf form definition files are 
  # stored in the /smerf directory.
  # 
  # To create a link to display a form you can use the Standard REST Path 
  # method used for the show action passing the name of the form definition file
  # as a parameter, for example
  #
  #   link_to('Complete Test Smerf Form', smerf_url('testsmerf'))  # Here is an example link that will display the <em>testsmerf</em> form
  # 
  def show
    # Retrieve the smerf form record, rebuild if required, also
    # retrieve the responses to this form if they exist
    retrieve_smerf_form(params[:id])
    @current_key = params[:key];
    @respondent = SurveyRespondent.find_by_single_access_token(params[:key]) 
    @page_title = 'Renovation Program Participant Questionnaire'

    if (@smerf_forms_surveyrespondent)
      # Retrieve the responses
      @responses = @smerf_forms_surveyrespondent.responses
      # Render in edit mode if the user has already completed this form
      render(:action => "edit")
    else
      # Render in create mode if the user have not completed this form
      render(:action => "create")      
    end        
  end

  # POST /smerf_forms
  # 
  # This method creates a new smerfs form record for the user that contains the 
  # users responses to the form. Once the record is saved a message to 
  # inform the user is added to <em>flash[:notice]</em> and displayed on 
  # the form. The form is redisplayed allowing the user to edit there responses 
  # to the questions on the form.
  # 
  def create
    # Make sure we have some responses
    if (params.has_key?("responses"))
      # Validate user responses
      validate_responses(params)
      # Save if no errors
      if (@errors.empty?()) 
        # Create the record 
        SmerfFormsSurveyrespondent.create_records(
          @smerfform.id, self.smerf_user_id, @responses)
        flash[:notice] = "#{@smerfform.name} saved successfully"

        #
        updateSurveyRespondent(self.smerf_user_id)
    
        render('survey_respondents/confirm')
      end
    else
      flash[:notice] = "No responses found in #{@smerfform.name}, nothing saved"      
    end
  end

  # PUT /smerf/1
  # 
  # This method will update an existing smerf form record for the user with 
  # the updated responses to the question on the form. Once the record is saved 
  # a message to inform the user is added to <em>flash[:notice]</em> and 
  # displayed on the form. The form is redisplayed allowing the user to further 
  # edit there responses to the questions. 
  #
  def update
    flash[:notice] = ""
    # Make sure we have some responses
    if (params.has_key?("responses"))
      # Validate user responses
      validate_responses(params)
      # Update responses if no errors
      if (@errors.empty?()) 
        SmerfFormsSurveyrespondent.update_records(
          @smerfform.id, self.smerf_user_id, @responses)
        flash[:notice] = "#{@smerfform.name} updated successfully"   
      end

      # 
      updateSurveyRespondent(self.smerf_user_id)
    
      render('survey_respondents/confirm')
    else
      flash[:notice] = "No responses found in #{@smerfform.name}, nothing saved"      
    end
  end
  
private

  def updateSurveyRespondent(id)
      # 
      survey_respondent = SurveyRespondent.find(id)
      SurveyMailer.deliver_thankyou_email(survey_respondent)
      
      smerf_forms_surveyrespondent = SmerfFormsSurveyrespondent.find_user_smerf_form(id, 1)
    
      survey_respondent.email = smerf_forms_surveyrespondent.responses['g4q6']
      survey_respondent.first_name = smerf_forms_surveyrespondent.responses['g2q1']
      survey_respondent.last_name = smerf_forms_surveyrespondent.responses['g2q3']
      survey_respondent.suffix = smerf_forms_surveyrespondent.responses['g2q4']
      
      # TODO - error handling?
      survey_respondent.save

  end
  
  # This method retrieves the smerf form and user responses if user
  # has already completed this form in the past.
  #
  def retrieve_smerf_form(id)
    # Retrieve the smerf form record if it exists
    @smerfform = SmerfForm.find_by_code(id)
    # Check if smerf form is active
    if (!@smerfform.code.blank?() and !@smerfform.active?())
      raise(RuntimeError, "#{@smerfform.name} is not active.")
    end   
    # Check if we need to rebuild the form, the form is built
    # the first time and then whenever the form definition file
    # is changed
    if (@smerfform.code.blank?() or 
      SmerfFile.modified?(params[:id], @smerfform.cache_date))        
      @smerfform.rebuild_cache(params[:id])
    end
    # Find the smerf form record for the current user
    @smerf_forms_surveyrespondent = SmerfFormsSurveyrespondent.find_user_smerf_form(
      self.smerf_user_id, @smerfform.id)
  end
  
  # This method will validate the users responses.
  #
  def validate_responses(params)
    @responses = params['responses'] 
    # Retrieve the smerf form record, rails will raise error if not found
    @smerfform = SmerfForm.find(params[:smerf_form_id])
    @smerfform.current_user = self.smerf_user_id # The id of the survey respondent
    @current_key = params[:key];
    # Validate user responses
    @errors = Hash.new()
    @smerfform.validate_responses(@responses, @errors)    
  end
end
