#
#
#
module ConstraintService
  
  #
  #
  #
  def self.updateNbrItemConstraints(sinceDate = nil)
    Person.transaction do
      itemsPerDayQuestion = SurveyQuestion.where(:questionmapping_id => QuestionMapping['ItemsPerDay']).order("created_at desc").first
      itemsPerConQuestion = SurveyQuestion.where(:questionmapping_id => QuestionMapping['ItemsPerConference']).order("created_at desc").first
      
      if itemsPerDayQuestion
        people = SurveyService.findPeopleWhoAnsweredQuestion(itemsPerDayQuestion,sinceDate)
        people.each do |person|
          surveyResponse = SurveyService.findResponseToQuestionForPerson(itemsPerDayQuestion,person,sinceDate)[0]
          
          itemsPerDay = surveyResponse.response.to_i
          
          person.person_constraints = PersonConstraints.new(:person_id => person.id) if !person.person_constraints
          person.person_constraints.max_items_per_day = itemsPerDay
          person.person_constraints.save!
        end
      end
      
      if itemsPerConQuestion
        people = SurveyService.findPeopleWhoAnsweredQuestion(itemsPerConQuestion,sinceDate)
        people.each do |person|
          surveyResponse = SurveyService.findResponseToQuestionForPerson(itemsPerConQuestion,person,sinceDate)[0]
          
          itemsPerCon = surveyResponse.response.to_i
          
          person.person_constraints = PersonConstraints.new(:person_id => person.id) if !person.person_constraints
          person.person_constraints.max_items_per_con = itemsPerCon
          person.person_constraints.save!
        end
      end
    end
  end
  
  #
  # Update People with the availability information from the Survey(s)
  #
  def self.updateAvailability(sinceDate = nil)
    Person.transaction do
      Time.use_zone(SiteConfig.first.time_zone) do
      # If there is more than one we want to take the latest as that will have the most current information for the participant
      availSurveyQuestion = SurveyQuestion.where(:question_type => :availability).order("created_at desc").first
      if (availSurveyQuestion != nil)
        people = SurveyService.findPeopleWhoAnsweredQuestion(availSurveyQuestion,sinceDate)
        startOfConference = Time.zone.parse(SiteConfig.first.start_date.to_s).beginning_of_day
        numberOfDays = SiteConfig.first.number_of_days
        
        people.each do |person|
          surveyResponse = SurveyService.findResponseToQuestionForPerson(availSurveyQuestion,person,sinceDate)[0]
          # NOTE - if a planner has updated the information for the person then we do not want to make a change
          next if ((person.available_date != nil) && (person.available_date.updated_at > surveyResponse.updated_at))

          if (surveyResponse != nil)
            if (surveyResponse.response == '2')
              if (surveyResponse.response2 && surveyResponse.response2 != '---')
                if (surveyResponse.response2.downcase == 'noon')
                   startTime = startOfConference + (12.hour) + (surveyResponse.response1.to_i).day
                else
                   startTime = startOfConference + (Time.zone.parse(surveyResponse.response2) - Time.zone.now.beginning_of_day) + (surveyResponse.response1.to_i).day
                end
              else
                startTime = startOfConference + 8.hour + (surveyResponse.response1.to_i).day
              end
              
              if (surveyResponse.response4 && surveyResponse.response4 != '---')
                if (surveyResponse.response4.downcase == 'noon')
                    endTime = startOfConference + 12.hour + (surveyResponse.response3.to_i).day
                else
                    endTime = startOfConference + (Time.zone.parse(surveyResponse.response4) - Time.zone.now.beginning_of_day) + (surveyResponse.response3.to_i).day
                end
              else
               endTime = startOfConference + 21.hour + (surveyResponse.response3.to_i).day
              end
              updateParams = { :start_time => startTime, :end_time => endTime}
              if (person.available_date != nil)
                if ((person.available_date.start_time != startTime) || (person.available_date.end_time != endTime))
                  available_date =  person.available_date
                  available_date.start_time = startTime
                  available_date.end_time = endTime
                  available_date.save
                end
              else
                person.create_available_date(updateParams)
              end
            end
          end
        end
      end
      end
    end
  end
  
  #
  # Update People with Excluded Times
  #
  def self.updateExcludedTimes(sinceDate = nil)
    Person.transaction do
      Time.use_zone(SiteConfig.first.time_zone) do
        excludedTimesMaps = ExcludedPeriodsSurveyMap.find :all
        
        Exclusion.delete_all({:excludable_type  => TimeSlot.name}) # clear out the time exclusions and then we recreate them
        
        peopleWithConstraints = []
        excludedTimesMaps.each do |excludedTimesMap|
          people = []
          if excludedTimesMap.survey_answer.answer && excludedTimesMap.survey_answer.survey_question_id
            if excludedTimesMap.survey_answer.answertype == AnswerType['TimeConflict']
              people = SurveyService.findPeopleWhoGaveAnswer(excludedTimesMap.survey_answer)
            else
              people = SurveyService.findPeopleWhoDidNotGiveAnswer(excludedTimesMap.survey_answer)
            end
            
            if people.size > 0 
              peopleWithConstraints.concat(people).uniq! # add these people to collection of people with constraints
              
              people.each do |person|
                # check that the exclusion is not already associated with the person
                if ! person.excluded_periods.include? excludedTimesMap.period
                  # if it is not then do the association
                  exclusion = Exclusion.new(
                    :person_id        => person.id,
                    :excludable_id    => excludedTimesMap.period_id,
                    :excludable_type  => TimeSlot.name,
                    :source           => 'survey'
                  )
                  
                  exclusion.save!
                end
              end
            end
          end
        end
      
      end
    end
  end
  
  #
  # Update People with Excluded Items
  #
  def self.updateExcludedItems(sinceDate = nil)
    Person.transaction do
      excludedItemMaps = ExcludedItemsSurveyMap.find :all # Get the map of exclusion from the survey, based on date that this was last run
  
      peopleWithConstraints = []
      excludedItemMaps.each do |excludedItemMap|
        since = nil
        since = ((excludedItemMap.updated_at < sinceDate) ? sinceDate : nil) if sinceDate# if there is a new mapping since the last time we ran then ignore the last run date
        if excludedItemMap.survey_answer
          people = SurveyService.findPeopleWhoGaveAnswer(excludedItemMap.survey_answer,since)
          peopleWithConstraints.concat(people).uniq! # add these people to collection of people with constraints
          
          people.each do |person|
            # check that the exclusion is not already associated with the person
            if ! person.excluded_items.include? excludedItemMap.programme_item
              # if it is not then do the association
              exclusion = Exclusion.new(
                :person_id        => person.id,
                :excludable_id    => excludedItemMap.programme_item_id,
                :excludable_type  => ProgrammeItem.name,
                :source           => 'survey'
              )
              
              exclusion.save!
            end
          end
        end
      end
      
      # Now we also want to remove exclusions that are no longer relevent
      exclusion_ids = excludedItemMaps.collect{|i| i.programme_item_id}.uniq
      people = getPeopleWithItemExclusions
      people.each do |person|
        candidate_ids = person.excluded_items.find_by_source('survey').collect{|i| i.id}.uniq - exclusion_ids
        if candidate_ids.size > 0
          candidates = candidate_ids.collect{|i| ProgrammeItem.find(i) }
          person.excluded_items.delete candidates
        end
        
        # check if person has an answer for the given exclusions
        # exclusions = person.excluded_items.find_by_source('survey') # all the exclusions they have
        # now see if they have corresponding survey answers
        answers = getPersonsSurveyAnswers(person.id, AnswerType["ItemConflict"].id)
        # we delete those that don't
        exclusions = excludedItemMaps.collect{|i| answers.include?(i.survey_answer_id) ? i.programme_item_id : nil }.compact.uniq
        candidate_ids = person.exclusions.where(['source = ? and excludable_type = ? and excludable_id not in (?)', 'survey', 'ProgrammeItem', exclusions]).pluck("excludable_id")
        if candidate_ids.size > 0
          Exclusion.delete_all(["excludable_id in (?) and excludable_type = ? and person_id = ?", candidate_ids,'ProgrammeItem',person.id])
        end
      end
    end
    
  end
  
  private
  
  #TODO - change
  def self.getPersonsSurveyAnswers(person_id, answer_type_id)
    
    survey_responses = Arel::Table.new(:survey_responses)
    survey_questions = Arel::Table.new(:survey_questions)
    survey_answers = Arel::Table.new(:survey_answers)
    survey_respondent_details = Arel::Table.new(:survey_respondent_details)
    survey_answers = Arel::Table.new(:survey_answers)
    survey_respondents = Arel::Table.new(:survey_respondents)
    
    attrs = [survey_answers[:id]]

    query = survey_responses.project(*attrs).
              join(survey_questions).on(survey_questions[:id].eq(survey_responses[:survey_question_id])).
              join(survey_answers).on(survey_answers[:survey_question_id].eq(survey_questions[:id])).
              join(survey_respondent_details).on(survey_respondent_details[:id].eq(survey_responses[:survey_respondent_detail_id])).
              join(survey_respondents).on(survey_respondents[:id].eq(survey_respondent_details[:survey_respondent_id]))

    query = query.where(survey_answers[:answertype_id].eq(answer_type_id).and(survey_respondents[:person_id].eq(person_id)))
    query = query.where(survey_responses[:response].eq(survey_answers[:answer]))

    query = query.where(self.arel_constraints())
    
    ActiveRecord::Base.connection.select_all(query.to_sql).uniq.collect{|a| a['id']}
  end

  def self.getPeopleWithItemExclusions
    Person.joins([:exclusions]).where("excludable_type = 'ProgrammeItem'").where(self.constraints())
  end

  def self.getPeopleWithTimeExclusions
    Person.joins([:exclusions]).where("excludable_type = 'TimeSlot'").where(self.constraints())
  end

  def self.constraints(*args)
    true
  end

  def self.arel_constraints(*args)
    true
  end
    
end
