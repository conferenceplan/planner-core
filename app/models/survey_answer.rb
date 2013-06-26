class SurveyAnswer < ActiveRecord::Base

  has_enumerated :answertype, :class_name => 'AnswerType'
  belongs_to :survey_question
  has_many :excluded_periods_survey_maps, :dependent => :destroy
  

def findExcludedPeriodMap(excludedList,inStart,inEnd)
  # find out if already entered
  foundMap = nil
  excludedList.each do |atime|
    if (inStart == atime.period.start && inEnd == atime.period.end)
      foundMap = atime
    end
  end
  return foundMap
end

def addExcludedPeriodMap(excludedStart,excludedEnd)
  excludedPeriod = Period.new 
  excludedPeriod.start = excludedStart
  excludedPeriod.end = excludedEnd
  excludedSurveyMap = ExcludedPeriodsSurveyMap.new
  excludedSurveyMap.period = excludedPeriod
  excluded_periods_survey_maps << excludedSurveyMap
  self.save
  return excludedSurveyMap
end

def updateTimeConflict(params)
  existingMaps = []

  if (answertype.name == 'TimeConflict')
    startOfConference = Time.zone.parse(SITE_CONFIG[:conference][:start_date])
    numberOfDays = SITE_CONFIG[:conference][:number_of_days]
    
    # this is just a 1 day conflict (if the day is set to numberOfDays, it is an
    # every day conflict
    if (start_day < numberOfDays)
      times = start_time.split(':') # hours and minutes
      currConflictStart = startOfConference + start_day.to_i.days + times[0].to_i.hours + times[1].to_i.minutes
      currConflictEnd = currConflictStart + duration.minutes
    
      foundMap = findExcludedPeriodMap(excluded_periods_survey_maps,currConflictStart,currConflictEnd)
      if (foundMap == nil)
          existingMaps << addExcludedPeriodMap(currConflictStart,currConflictEnd)
       else
          existingMaps << foundMap
      end
    else
      # this is the ALL days case
      if (start_day == numberOfDays)
        times = start_time.split(':') # hours and minutes
        currConflictStart = startOfConference + times[0].to_i.hours + times[1].to_i.minutes
        currConflictEnd = currConflictStart + duration.minutes
        
        numberOfDays.times { 
           foundMap = findExcludedPeriodMap(excluded_periods_survey_maps,currConflictStart,currConflictEnd)
           if (foundMap == nil)
              existingMaps << addExcludedPeriodMap(currConflictStart,currConflictEnd)
           else
              existingMaps << foundMap
           end
           currConflictStart = currConflictStart + 1.day
           currConflictEnd = currConflictEnd + 1.day
       }
      end
    end
  end
  
  # delete all old maps if they no longer apply
  # find out if already entered    
  excluded_periods_survey_maps.each do |atime|
     foundMap = findExcludedPeriodMap(existingMaps,atime.period.start,atime.period.end)
     if (foundMap == nil)
        # TODO clean up exclusion table or don't allow delete?
       atime.destroy
     end
  end
end

end
