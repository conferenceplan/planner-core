#
#
#
require 'planner_report_helpers'

class SurveyReportsController < PlannerController
  include PlannerReportHelpers
  
  #
  #
  #
  def extract_all
    # for a survey generate an excel with all the answers
    survey = Survey.find params[:survey_id]
    fname = survey.name.gsub(/[^a-zA-Z\d]/, '')
    
    @questions = SurveyQuestion.unscoped.includes(:survey_group).
                        where({ :'survey_groups.survey_id' =>  survey.id}).
                        order("survey_groups.sort_order, survey_questions.sort_order")

    # Build a map of questions to columns
    @question_column = Hash.new
    i = 0
    @questions.each do |question|
      @question_column[question.id] = i
      i += 1 if question.question_type == :availability
      i += 1
    end
    @nbr_question_cols = i

    @respondents = SurveyRespondentDetail.includes([{:survey_responses => {:survey_question => :survey_group}}]).
                        where({ :'survey_responses.survey_id' =>  survey.id}).
                        order("survey_respondent_details.last_name, survey_groups.sort_order, survey_questions.sort_order")

    respond_to do |format|
      format.xlsx{
        response.headers['Content-Disposition'] = 'attachment; filename="' + fname + '_' + Time.now.strftime("%m-%d-%Y") + '.xlsx"'
      }
    end
  end
  
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
        output.push ['Prefix', 'First Name', 'Last Name', 'Suffix', 'Organization', 'Email', 'Date Filled'].concat @meta_data.collect{ |cn| cn[1][:question] }

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
            result.company,
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
    @missing_bio = Person.
                      references(:edited_bio).
                      joins({:survey_respondent => {:survey_respondent_detail => :survey_responses}}).
                      where({:survey_responses => {:isbio => true}, :edited_bios => { :person_id => nil} }).
                      order("people.last_name ASC")
  end

end
