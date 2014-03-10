#
#
#
class SurveyReportsController < PlannerController
  include PlannerReportHelpers
  
  #
  #
  #  
  def runReport
    # Get the query from the database
    surveyQuery = SurveyQuery.find params[:query_id]
    
    # Run the query
    result = SurveyService.runReport(surveyQuery)    

    respond_to do |format|
      format.json {
        # Return the results as a JSON structure
        render json: '{ "show_country" : ' + surveyQuery.show_country.to_s + ', "totalpages": 1, "currpage": 1, "totalrecords": ' + result[:count].to_s + 
                        ', "userdata": ' + result[:meta_data].to_json() + 
                        ', "rowdata": ' + result[:result_set].to_json() + 
                        '}', :content_type => 'application/json'
      }
      format.csv {
        outfile = "survey_report_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        output = Array.new
        output.push ['First Name', 'Last Name', 'Email', 'Date Filled'].concat result[:meta_data].collect{ |cn| cn[1]['question'] }
        
        result[:result_set].each do |res|
          output.push [ res['first_name'], res['last_name'], res['email'], res['filled_at'] ].concat result[:meta_data].collect{ |cn| res[cn[0]] }
        end
        
        csv_out(output, outfile)
      }
    end
    
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

end
