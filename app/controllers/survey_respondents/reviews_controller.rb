class SurveyRespondents::ReviewsController < ApplicationController
  before_filter :require_user

# 1. List of survey respondents
# 2. 
# 3.

  def index
  end

  def show
    # Get the respondent
    respondent = SurveyRespondent.find(params[:id])
    
    # Get the survey
    @smerf_user_id = respondent.id # check
#    @respondent_form = SmerfFormsSurveyrespondent.find_user_smerf_form(respondent.id, 1)
    @form = SmerfForm.find_by_id(1)
    smerf_forms_surveyrespondent = SmerfFormsSurveyrespondent.find_user_smerf_form(respondent.id, 1)
    @responses = smerf_forms_surveyrespondent.responses

    render :layout => 'content'
  end

  def list
    j = ActiveSupport::JSON
    
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]
    clause = ""
    fields = Array::new
    
    if (params[:filters])
      queryParams = j.decode(params[:filters])
      if (queryParams)
        clausestr = ""
        queryParams["rules"].each do |subclause|

          # these are the select type filters - position 0 is the empty position and means it is not selected, so we are not
          # filtering on that item
          if clausestr.length > 0 
            clausestr << ' ' + queryParams["groupOp"] + ' '
          end
          # integer items (integers or select id's) need to be handled differently in the query
              if subclause["op"] == 'ne'
                clausestr << subclause['field'] + ' not like ?'
              else
                clausestr << subclause['field'] + ' like ?'
              end
              fields << subclause['data'] + '%'
          logger.info fields
        end
        clause = [clausestr] | fields
      end
    end

    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB
    count = SurveyRespondent.count :conditions => clause
    @nbr_pages = (count / rows.to_i).floor + 1
    
    off = (@page.to_i - 1) * rows.to_i
    @respondents = SurveyRespondent.find :all, :offset => off, :limit => rows,
      :order => idx + " " + order, :conditions => clause
   
    # We return the list of people as an XML structure which the 'table' can us
    respond_to do |format|
      format.xml
    end
  end

end
