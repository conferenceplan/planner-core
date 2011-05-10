class ExcludedTimesController < ApplicationController
   def show
     if (params[:person_id])
       @person = Person.find(params[:person_id])
       excludedTimes = person.excluded_items
       excludedTimes.sort!
       # we need to figure out if we have daily repeating exclusions
       excludedGroup = {}
       inExcludedGroup = {}
       excludedTimes.each do |excluded|
         next if (inExcludedGroup.has_key? excluded)
         
         excludedList = [excluded]
         excludedGroup[excluded] = excludedList
         inExcludedGroup[excluded] = 1
         excludedTimes.each do |excluded1|
             if ((excluded.hour == excluded1.hour) and (excluded.min == excluded1.min) and (excluded.day != excluded1.day))
                excludedGroup[excluded] << excluded1
                inExcludedGroup[excluded1] = 1
             end
          end
        end
      
    end
    
    render :layout => 'content'
  end
  def PopulateExcludedTimesMap
    excludedTimesMap = ExcludedPeriodsSurveyMap.find :all
    if (excludedTimesMap.size == 0)
   
       startOfConference = Time.zone.parse(SITE_CONFIG[:conference][:start_date])
       numberOfDays = SITE_CONFIG[:conference][:number_of_days]
    
       currBefore11StartTime = startOfConference + 8.hours
       currBefore11EndTime = startOfConference + 11.hours
       currBetween6and8StartTime = startOfConference + 18.hours
       currBetween6and8EndTime = startOfConference + 20.hours
       currAfter8StartTime = startOfConference + 20.hours
       currAfter8EndTime = startOfConference + 24.hours
       
       numberOfDays.times { 
       
       excludedPeriod = Period.new 
       excludedPeriod.start = currBefore11StartTime
       excludedPeriod.end = currBefore11EndTime
       excludedTimesSurveyMap = ExcludedPeriodsSurveyMap.new
       excludedTimesSurveyMap.survey_question = 'g6q4'
       excludedTimesSurveyMap.survey_code = '1'
       excludedTimesSurveyMap.period = excludedPeriod
       excludedTimesSurveyMap.description = 'Not Before 11am'
       excludedTimesSurveyMap.save
       
       excludedPeriod = Period.new 
       excludedPeriod.start = currBetween6and8StartTime
       excludedPeriod.end = currBetween6and8EndTime
       excludedTimesSurveyMap = ExcludedPeriodsSurveyMap.new
       excludedTimesSurveyMap.survey_question = 'g6q4'
       excludedTimesSurveyMap.survey_code = '2'
       excludedTimesSurveyMap.description = 'Not Between 6 and 8'
       excludedTimesSurveyMap.period = excludedPeriod
       excludedTimesSurveyMap.save
       
       excludedPeriod = Period.new 
       excludedPeriod.start = currAfter8StartTime
       excludedPeriod.end = currAfter8EndTime
       excludedTimesSurveyMap = ExcludedPeriodsSurveyMap.new
       excludedTimesSurveyMap.survey_question = 'g6q4'
       excludedTimesSurveyMap.survey_code = '3'
       excludedTimesSurveyMap.period = excludedPeriod
       excludedTimesSurveyMap.description = 'Not After 8pm'
       excludedTimesSurveyMap.save
       
       currBefore11StartTime = currBefore11StartTime + 1.day
       currBefore11EndTime = currBefore11EndTime + 1.day
       currBetween6and8StartTime = currBetween6and8StartTime + 1.day
       currBetween6and8EndTime = currBetween6and8EndTime + 1.day
       currAfter8StartTime = currAfter8StartTime + 1.day
       currAfter8EndTime = currAfter8EndTime + 1.day
      }
    end
  end
end
