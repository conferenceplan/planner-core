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
        output.push ['Prefix', 'First Name', 'Last Name', 'Suffix', 'Email', 'Date Filled'].concat @meta_data.collect{ |cn| cn[1][:question] }

        @result.each do |result|
          answers = {}
          result.survey_responses.each do |res|
              if (@meta_data[res.survey_question_id][:question_type] == :multiplechoice) && answers[res.survey_question_id.to_s]
                  answers[res.survey_question_id.to_s] += '; ' + res.response
              elsif (@meta_data[res.survey_question_id][:question_type] == :availability)
                  if res.response5
                      answers[res.survey_question_id.to_s] = "I am extremely uncertain when I will be available to be on the Program"
                  else
                      answers[res.survey_question_id.to_s] = res.response == '1' ? 'I am available for Program for the complete duration of the convention' : 'I plan to be at the convention.'
                      if res.response == '2'
                          answers[res.survey_question_id.to_s] += ": " + (Time.zone.parse(@site_config.start_date.to_s) + res.response1.to_i.day).strftime('%A, %B %e') + ", " + res.response2
                          answers[res.survey_question_id.to_s] += " => " + (Time.zone.parse(@site_config.start_date.to_s) + res.response3.to_i.day).strftime('%A, %B %e') + ", " + res.response4
                      end
                  end
              else
                  answers[res.survey_question_id.to_s] = res.response
              end
          end

          output.push [
            result.prefix,
            result.first_name,
            result.last_name,
            result.suffix,
            result.email,
            result.survey_histories.first.filled_at.strftime('%I:%M %p, %d %B %Y')
          ].concat @meta_data.collect{ |cn| answers[cn[0].to_s] }
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
