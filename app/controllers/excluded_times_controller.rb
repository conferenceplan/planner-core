class ExcludedTimesController < PlannerController
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
end
