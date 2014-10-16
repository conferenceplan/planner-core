#
#
#
require 'planner_report_helpers'

class SurveyReportsController < PlannerController
  include PlannerReportHelpers
  
  #
  #
  #
  def runReport
    # Get the query from the database
    surveyQuery = SurveyQuery.find params[:query_id]
    
    @meta_data = {}
    @show_country = surveyQuery.show_country
    @site_config = SiteConfig.first
    
    surveyQuery.survey_query_predicates.each do |p|
      @meta_data[p.survey_question.id] = {:question_type => p.survey_question.question_type, :question => p.survey_question.question, :id =>p.survey_question.id }
    end
    
    # Run the query
    @result = SurveyService.executeReport(surveyQuery)
    
    # TODO - if ALL is selected then filter the result set for all predicates to have an answer

    respond_to do |format|
      format.json
      format.csv {
        outfile = "survey_report_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        # TODO -
        output = Array.new
        output.push ['First Name', 'Last Name', 'Email', 'Date Filled'].concat @meta_data.collect{ |cn| cn[1][:question] }

          # output.push [ res['first_name'], res['last_name'], res['email'], res['filled_at'] ].concat result[:meta_data].collect{ |cn| res[cn[0]] }
        
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
