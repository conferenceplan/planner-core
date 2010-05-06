class ProgrammeItemAssignment < ActiveRecord::Base
  belongs_to  :person
  belongs_to  :programmeItem
end
