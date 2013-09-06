module PlannerReportHelpers
   require 'csv'
 
   def csv_out(data, filename)
      csv_data = CSV.generate encoding: 'ISO-8859-15' do |csv|
         data.each do |r|
            csv << r
         end
      end
      send_data csv_data.encode('ISO-8859-15', :invalid => :replace, :undef => :replace),
         :type => 'text/csv; charset=iso-8859-15; header=present',
         :disposition => "attachment; filename=#{filename}"
      flash[:notice] = "Export complete!"
   end

   def csv_out_utf16(data, filename)
      csv_data = CSV.generate :encoding => 'UTF-16' do |csv|
         data.each do |r|
            csv << r
         end
      end
      send_data csv_data.encode('UTF-16', :invalid => :replace, :undef => :replace),
         :type => 'text/csv; charset=utf-16; header=present',
         :disposition => "attachment; filename=#{filename}"
      flash[:notice] = "Export complete!"
   end

   def csv_out_noconv(data, filename)
      csv_data = CSV.generate do |csv|
         data.each do |r|
            csv << r
         end
      end
      send_data csv_data,
         :type => 'text/csv; charset=utf-8; header=present',
         :disposition => "attachment; filename=#{filename}"
      flash[:notice] = "Export complete!"
   end

   def generate_schedule_csv

      maxquery = "select MAX(x) from (select Count(*) as x from programme_item_assignments group by person_id) l;"
      maxList = ActiveRecord::Base.connection.select_rows(maxquery)
      maxItems = maxList[0][0].to_i;
      maxPanelInRoom = 0

      if (params[:schedule] != nil)
         peopleList = params[:schedule][:person_id]
         categoryList = params[:schedule][:invitation_category_id]
      end

      @NoShareEmailers = SurveyService.findPeopleWithDoNotShareEmail

      selectConditions = ''

      if (peopleList != nil && peopleList.size() != 0)
         addOr = "AND ("
         peopleList.each do |p|
            selectConditions = selectConditions + addOr + 'people.id ='+ p
            addOr = " OR "
         end
         selectConditions = selectConditions + ")"
      end

      if (categoryList != nil && categoryList.size() != 0)
         addOr = "AND ("      
         categoryList.each do |p|
            selectConditions = selectConditions + addOr + 'people.invitation_category_id ='+ p
            addOr = " OR "
         end
         selectConditions = selectConditions + ")"
      end

      outfile = "schedule_" + Time.now.strftime("%m-%d-%Y") + ".csv"

      CSV.open(outfile, "w") do |csv|
        csv << "Name"
        csv << "email"
        1.upto(maxItems) do |number|
          numberString = number.to_s
          headerValue = "Title"+numberString
          csv << headerValue
          headerValue = "Room"+numberString
          csv << headerValue
          headerValue = "Venue"+numberString
          csv << headerValue
          headerValue = "StrTime"+numberString
          csv << headerValue
          headerValue = "Description"+numberString
          csv << headerValue
          headerValue = "Participants"+numberString
          csv << headerValue
          headerValue = "Equipment"+numberString
          csv << headerValue
        end
  logger.debug "before retrieval loop: #{Time.now}" 
     
        Person.find_each(
          :conditions => ['((programme_item_assignments.person_id = people.id) AND (programme_item_assignments.role_id in (?)) AND (people.acceptance_status_id in (?)))' + selectConditions,
          [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id,PersonItemRole['Invisible'].id],
          [AcceptanceStatus['Accepted'].id, AcceptanceStatus['Probable'].id]],
          :include => [:email_addresses, {:programmeItems => [{:programme_item_assignments => {:person => [:pseudonym, :email_addresses]}}, 
          :equipment_types, {:room => :venue}, :time_slot]} ]
        ) do |person|
          panellist = []
          defaultEmail = ''
          if (params[:incl_email])
            person.email_addresses.each do |addr|
              if addr.isdefault
                defaultEmail = addr.email
              end
            end
          end

          person.programmeItems.each do |itm|
            next if itm.time_slot.nil?
            names = []
            panelinfo = {}

            itm.programme_item_assignments.each do |asg| 
              if asg.role == PersonItemRole['Participant'] || asg.role == PersonItemRole['Moderator']      
                name = asg.person.getFullPublicationName()
                name += " (M)" if asg.role == PersonItemRole['Moderator']  
  
                if (params[:incl_email])
                  asg.person.email_addresses.each do |addr|
                    if addr.isdefault && (!@NoShareEmailers.index(asg.person))
                      name += "(" + addr.email + ")"
                    end
                  end
                end
  
                names << name
              end
            end
  
            equipList = []

            if itm.equipment_types.size == 0
              equipList << "No Equipment Needed"
            end
  
            itm.equipment_types.each do |equip|
              equipList << equip.description
            end
  
            panelinfo = {}
            panelinfo['title'] = itm.title
            panelinfo['room'] = itm.room.name
            panelinfo['venue'] = itm.room.venue.name
            panelinfo['time'] = itm.time_slot.start.strftime('%Y-%m-%d %H:%M')
            panelinfo['strtime'] = "#{itm.time_slot.start.strftime('%a %H:%M')} - #{itm.time_slot.end.strftime('%H:%M')}"
            description = itm.precis.gsub('\n','')
            description = description.gsub('\r','')
            panelinfo['description'] = description
            panelinfo['participants'] = names.join(', ')
            panelinfo['equipment'] = equipList.join(', ')                      
            panellist << panelinfo
               
          end # person.programmeItems.each do |itm|
          panellist.sort! {|a,b| a['time'] <=> b['time']}

          csv << person.getFullPublicationName
          csv << defaultEmail
          1.upto(maxItems) do |num|
            if (panellist.size() != 0 && num <= panellist.size())
              csv << panellist[num-1]['title']
              csv << panellist[num-1]['room']
              csv << panellist[num-1]['venue']
              csv << panellist[num-1]['strtime']
              csv << panellist[num-1]['description']
              csv << panellist[num-1]['participants']
              csv << panellist[num-1]['equipment']
            else
              csv << "";
              csv << "";
              csv << "";
              csv << "";
              csv << "";
              csv << "";
              csv << "";
            end
          end
        end # Person.find_each(
      end #CSV.open(outfile, "w") do |csv|
      logger.debug "after retrieval loop: #{Time.now}" 
   end
end
