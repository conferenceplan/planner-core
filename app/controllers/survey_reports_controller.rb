#
#
#
class SurveyReportsController < PlannerController
  include SurveyReportHelpers
  include PlannerReportHelpers
  
  def index
  end
 
  def library_talks
    @library_talkers = search_survey_exact('g93q7', '1')
  end
 
  def interviewable
    @interviewable = search_survey_exact('g93q7', '4')
  end
 
  def missing_bio
    @missing_bio = Person.all :joins => 'join survey_respondents on people.id = survey_respondents.person_id left join edited_bios on survey_respondents.person_id = edited_bios.person_id', :conditions => "edited_bios.id is NULL and survey_respondents.attending = '1' and survey_respondents.submitted_survey = '1' and people.invitestatus_id = 5 and people.acceptance_status_id = 8", :order => 'last_name'
  end
  
  def moderators
    @moderators = search_survey_exact('g9q4', '1')
  end
 
  def music_night
    @music_night = search_survey('g91q1', '%')
  end

  def art_night
    @art_night = search_survey('g92q1', '%')
  end

  def program_types
    @program_types = GetProgramTypes()
    @interested = search_survey_exact('g9q1', params[:type_id])
  end
 
  def free_text
    @free_text_qs = GetFreeTextQuestions()
    if params[:q_id]
      search_string = '%'+params[:search_string]+'%'
      @names = search_survey(params[:q_id], search_string)
    end
  end
  
  def tags_by_context
    taggings = ActsAsTaggableOn::Tagging.find :all,
                  :select => "DISTINCT(context)",
                  :conditions => "taggable_type like 'Person'"
                  
    @contexts = Array.new

    # for each context get the set of tags (sorted), and add them to the collection for display on the page
    taggings.each do |tagging|
      @contexts << tagging.context
    end

    if params[:tag]
      logger.debug params[:tag][:context]
      @context = params[:tag][:context]
      
      @names = Person.all(:joins => "INNER JOIN taggings ON taggings.taggable_type = 'Person' AND taggings.taggable_id = people.id AND taggings.context = '" + @context +"'",
                    :select => "DISTINCT people.* ",
                    :order => "people.last_name ASC")
    end
  end
 
  def available_during
    @conflicts = GetConflictItems()
    if params[:conflict_id]
      (q_id, target) = params[:conflict_id].split('|')
      @names = search_survey_negative(q_id, target)
    end
  end

  def panelists_with_metadata
     outfile = "panelist_details" + Time.now.strftime("%m-%d-%Y") + ".csv"
     output = Array.new
     output.push ['Name',
                  'Start Day',
                  'Start Time',
                  'End Day',
                  'End Time',
                  'Max per Day',
                  'Max Total',
                  'Invitation Category',
                  'Registered',
                 ]
     @names = search_survey('g6q1', '%')
     @names.each do |n|
        output.push [ n.GetFullPublicationName,
                      n.GetSurveyStartDate.strftime('%a'),
                      n.GetSurveyStartDate.strftime('%H:%M'),
                      n.GetSurveyEndDate.strftime('%a'),
                      n.GetSurveyEndDate.strftime('%H:%M'),
                      n.GetSurveyQuestionResponse('g6q2'), 
                      n.GetSurveyQuestionResponse('g6q3'),
                      n.invitation_category.nil? ? '--' : n.invitation_category.name.nil? ? '--' : n.invitation_category.name,
                      n.registrationDetail.nil? ? '--' : n.registrationDetail.registration_type.nil? ? '--': n.registrationDetail.registration_type
                    ]
     end
     csv_out_utf16(output, outfile)
  end

end
