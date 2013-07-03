#
#
#
module ProgramItemsService
  
  #
  #
  #
  def self.findProgramItemsForPerson(person)
    ProgrammeItemAssignment.all(
        :conditions => ['(programme_item_assignments.person_id = ?) AND (programme_item_assignments.role_id in (?))', 
            person.id, 
            [PersonItemRole['Participant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Speaker'].id,PersonItemRole['Invisible'].id]],
            :include => {:programmeItem => [{:programme_item_assignments => {:person => [:pseudonym, :email_addresses]}}, :equipment_types, {:room => :venue}, :time_slot]},
            :order => "time_slots.start asc"
    )
  end
  
end
