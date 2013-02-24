class SurveyRespondents::ReviewsController < PlannerController

  def index
  end

  def show
    # Get the respondent
    # @form = nil
    if !@survey
      @survey = Survey.find_by_alias('partsurvey') #find(params[:survey_id])
    end
  
    # we need the survey and the survey respondent
    @respondent = SurveyRespondent.find(params[:id])
    
    
    # @form = nil
    # if (respondent.length >  0)
      # # Get the survey
      # @smerf_user_id = respondent[0].id 
      # @form = SmerfForm.find_by_id(1)
      # smerf_forms_surveyrespondent = SmerfFormsSurveyrespondent.find_user_smerf_form(respondent[0].id, 1)
      # if (smerf_forms_surveyrespondent)
        # @responses = smerf_forms_surveyrespondent.responses
      # else
        # @form = nil
      # end
    # end

    render :layout => 'content'
  end

  def list
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]

    clause = createWhereClause(params[:filters])
    clause = addClause(clause, 'submitted_survey = ?', true)

    clause = addClause(clause,'people.acceptance_status_id != ? ',9)
    args = { :conditions => clause }
    args.merge!( :joins => 'LEFT JOIN people ON people.id = survey_respondents.person_id' )

    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB      
    @count = SurveyRespondent.count args
    @nbr_pages = (@count / rows.to_i).floor + 1
    @nbr_pages += 1 if @count % rows.to_i > 0
    
    off = (@page.to_i - 1) * rows.to_i
    args.merge!(:offset => off, :limit => rows, :order => idx + " " + order)

    @respondents = SurveyRespondent.find :all, args
   
    # We return the list of people as an XML structure which the 'table' can us
    respond_to do |format|
      format.xml
    end
  end
  
  def states
    @copyStatus = SurveyCopyStatus.first :conditions => ["survey_respondent_id = ?", params[:id]]
    @respondentId = params[:id]
    
    render :layout => 'content'
  end
  
  # @@surveyFields = {
    # :name => ['g2q1', 'g2q3', 'g2q4'], # first, last, suffix
    # :pseudonym => ['g3q1', 'g3q3', 'g3q4'],
    # :address => ['g4q1', 'g4q2', 'g4q3', 'g4q4', 'g4q5'], # street, city, state, zip, country
    # :phone => ['g4q7', 'g4q7p1'], # phone type, phone number - add -N for each additional up to 4
    # :email => 'g4q6' # add -N for each additional up to 3
  # }
#   
  # def copySurvey
    # respondent = SurveyRespondent.find(params[:id])
    # @respondentId = params[:id]
    # person = respondent.person
    # survey = SmerfFormsSurveyrespondent.find_user_smerf_form(respondent.id, 1)
# 
    # @copyStatus = SurveyCopyStatus.find :first, :conditions => ['person_id = ?', person] 
    # if @copyStatus == nil
      # @copyStatus = SurveyCopyStatus.new
      # @copyStatus.person = person
      # @copyStatus.survey_respondent = respondent
    # end
#     
    # # 1. copy the information selected from the survey and put it into the person
    # copyName(survey, person, @copyStatus) if params[:name] != nil
    # copyPseudonym(survey, person, @copyStatus) if params[:pseudonym] != nil
    # copyAddress(survey, person, @copyStatus) if params[:address] != nil
    # copyPhone(survey, person, @copyStatus) if params[:phone] != nil
    # copyEmail(survey, person, @copyStatus) if params[:email] != nil
    # copyTags(respondent, person, @copyStatus) if params[:tags] != nil
    # copyAvailableDates(respondent, person, @copyStatus) if params[:available_date]
    # # 2. update the status with the information
    # if (person.save)
      # @copyStatus.save
      # # 3. Render the form again
      # render 'states.html', :layout => 'content'
    # else
      # # TODO - change this to a better error report
      # render :inline => 'problem with copy'
    # end
  # end
#   
  # def copyName(survey, person, copystatus)
    # person.first_name = survey.responses[@@surveyFields[:name][0]]
    # person.last_name = survey.responses[@@surveyFields[:name][1]]
    # person.suffix = survey.responses[@@surveyFields[:name][2]]
    # copystatus.nameCopied = true
  # end
# 
  # def copyPseudonym(survey, person, copystatus)
    # # FIX
    # if person.pseudonym == nil
      # person.pseudonym = Pseudonym.new
    # end
    # person.pseudonym.first_name = survey.responses[@@surveyFields[:pseudonym][0]]
    # person.pseudonym.last_name = survey.responses[@@surveyFields[:pseudonym][1]]
    # person.pseudonym.suffix = survey.responses[@@surveyFields[:pseudonym][2]]
    # copystatus.pseudonymCopied = true
  # end
#   
  # def copyAddress(survey, person, copystatus)
    # # Add the address
    # addr = person.postal_addresses.new
    # addr.line1 = survey.responses[@@surveyFields[:address][0]]
    # addr.city = survey.responses[@@surveyFields[:address][1]]
    # addr.state = survey.responses[@@surveyFields[:address][2]]
    # addr.postcode = survey.responses[@@surveyFields[:address][3]]
    # addr.country = survey.responses[@@surveyFields[:address][4]]
    # copystatus.addressCopied = true
  # end
# 
  # def copyPhone(survey, person, copystatus)
    # # Add the phone 4 times
    # suf = ''
    # 0.upto(3) { |i|
      # suf = '-' + i.to_s if i > 0
      # phonetype = survey.responses[@@surveyFields[:phone][0] + suf] # type
      # phonenumber = survey.responses[@@surveyFields[:phone][1] + suf] # number
      # if phonenumber != nil && phonenumber != ''
        # place = person.phone_numbers.index{ |ph| ph.number == phonenumber }
#         
        # if place == nil
          # phone = person.phone_numbers.new
          # phone.number = phonenumber
          # phone.phone_type = PhoneTypes[:Other]
          # case phonetype.to_i
            # when 1
            # phone.phone_type = PhoneTypes[:Home]
            # when 2
            # phone.phone_type = PhoneTypes[:Work]
            # when 3
            # phone.phone_type = PhoneTypes[:Mobile]
            # when 4
            # phone.phone_type = PhoneTypes[:Fax]
          # end
        # end
      # end
    # }
#     
    # copystatus.phoneCopied = true
  # end
# 
  # def copyEmail(survey, person, copystatus)
    # # Add the email 3 times
    # survey.responses[@@surveyFields[:email][0]]
# 
    # suf = ''
    # 0.upto(2) { |i|
      # suf = '-' + i.to_s if i > 0
      # email = survey.responses[@@surveyFields[:email] + suf] # email
      # if email != nil && email != ''
        # place = person.email_addresses.index{ |addr| addr.email == email }
        # if place == nil
          # newemail = person.email_addresses.new
          # newemail.email = email
          # newemail.isdefault = i == 0
        # end
      # end
    # }
#     
    # copystatus.emailCopied = true
  # end
# 
  # def copyTags(respondent, person, copystatus)
    # # copy the tags from the respondent to the person
    # tagContexts = getContexts
#     
    # tagContexts.each do |context|
      # tags = respondent.tag_list_on(context)
      # tagstr = tags * ","
      # if tags
        # person.set_tag_list_on(context, tagstr)
      # end
    # end
#     
    # # go through each of the tag contexts attached to the respondent and set the same information in the person
    # copystatus.tagsCopied = true
  # end
#   
  # def copyAvailableDates(respondent,person,copystatus)
      # startTime = person.GetSurveyStartDate
      # endTime = person.GetSurveyEndDate
      # if (startTime && endTime)
          # updateParams = { :start_time => startTime, :end_time => endTime}
          # @availableDate = person.create_available_date(updateParams)
          # copystatus.availableDatesCopied = true
      # end
  # end
#   
  # def getContexts
    # taggings = ActsAsTaggableOn::Tagging.find :all,
                  # :select => "DISTINCT(context)",
                  # :conditions => "taggable_type like 'SurveyRespondent'"
#                   
    # tagContexts = Array.new
# 
    # # for each context get the set of tags (sorted), and add them to the collection for display on the page
    # taggings.each do |tagging|
      # tagContexts << tagging.context
    # end
#     
    # return tagContexts
  # end

end
