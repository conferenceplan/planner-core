#
#
#
class SurveyReportsController < PlannerController
  
  #
  #
  #  
  def runReport
    # Get the query from the database
    surveyQuery = SurveyQuery.find params[:query_id]
    
    # Run the query
    result = SurveyService.runReport(surveyQuery)    
    
    # Return the results as a JSON structure
    render json: '{ "totalpages": 1, "currpage": 1, "totalrecords": ' + result[:count].to_s + 
                    ', "userdata": ' + result[:meta_data].to_json() + 
                    ', "rowdata": ' + result[:result_set].to_json() + 
                    '}', :content_type => 'application/json'
  end

  #
  #
  #  
  def missing_bio
    @missing_bio = Person.all :joins => {:survey_respondent => {:survey_respondent_detail => :survey_responses}}, 
                :include => :edited_bio,
                :conditions => {:survey_responses => {:isbio => true}, :edited_bios => { :person_id => nil} },
                :order => "people.last_name ASC"
  end

  # def tags_by_context
    # taggings = ActsAsTaggableOn::Tagging.find :all,
                  # :select => "DISTINCT(context)",
                  # :conditions => "taggable_type like 'Person'"
#                   
    # @contexts = Array.new
# 
    # # for each context get the set of tags (sorted), and add them to the collection for display on the page
    # taggings.each do |tagging|
      # @contexts << tagging.context
    # end
# 
    # if params[:tag]
      # logger.debug params[:tag][:context]
      # @context = params[:tag][:context]
#       
      # @names = Person.all(:joins => "INNER JOIN taggings ON taggings.taggable_type = 'Person' AND taggings.taggable_id = people.id AND taggings.context = '" + @context +"'",
                    # :select => "DISTINCT people.* ",
                    # :order => "people.last_name ASC")
    # end
  # end
 
end
