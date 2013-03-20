#
#
#
class SurveyReportsController < PlannerController
  include PlannerReportHelpers
  
  def index
  end
 
  def library_talks
    @library_talkers = Person.all :joins => {:survey_respondent => {:survey_respondent_detail => {:survey_responses => :survey_question}}}, 
                :conditions => {:survey_questions => {:id => 73}, :survey_responses => {:response => 62}},
                :order => "people.last_name ASC"
  end
 
  def interviewable
    @interviewable = Person.all :joins => {:survey_respondent => {:survey_respondent_detail => {:survey_responses => :survey_question}}}, 
                :conditions => {:survey_questions => {:id => 73}, :survey_responses => {:response => 68}},
                :order => "people.last_name ASC"
  end
 
  def missing_bio
    @missing_bio = Person.all :joins => {:survey_respondent => {:survey_respondent_detail => :survey_responses}}, 
                :include => :edited_bio,
                :conditions => {:survey_responses => {:isbio => true}, :edited_bios => { :person_id => nil} },
                :order => "people.last_name ASC"
  end

  # TODO - these are a temp queries for LSC  
  def moderators
    @moderators = Person.all :joins => {:survey_respondent => {:survey_respondent_detail => {:survey_responses => :survey_question}}}, 
                :conditions => {:survey_questions => {:id => 56}, :survey_responses => {:response => 55}},
                :order => "people.last_name ASC"
  end
 
  def music_night
    @music_night = Person.all :select => "people.*, survey_responses.response",
                :joins => {:survey_respondent => {:survey_respondent_detail => {:survey_responses => :survey_question}}}, 
                :conditions => "survey_questions.id = 61 AND survey_responses.response <> ''", #{:survey_questions => {:id => 61}, :survey_responses => {:response => '' }},
                :order => "people.last_name ASC"
  end

  def art_night
    @art_night = Person.all :select => "people.*, survey_responses.response",
                :joins => {:survey_respondent => {:survey_respondent_detail => {:survey_responses => :survey_question}}}, 
                :conditions => "survey_questions.id = 62 AND survey_responses.response <> ''", #{:survey_questions => {:id => 61}, :survey_responses => {:response => '' }},
                :order => "people.last_name ASC"
  end

  def program_types
    # @program_types = GetProgramTypes()
    # @interested = search_survey_exact('g9q1', params[:type_id])
  end
 
  def free_text
    # @free_text_qs = GetFreeTextQuestions()
    # if params[:q_id]
      # search_string = '%'+params[:search_string]+'%'
      # @names = search_survey(params[:q_id], search_string)
    # end
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
    # @conflicts = GetConflictItems()
    # if params[:conflict_id]
      # (q_id, target) = params[:conflict_id].split('|')
      # @names = search_survey_negative(q_id, target)
    # end
  end

  def panelists_with_metadata
    @names = []
  end

end
