class TimeSlot < ActiveRecord::Base

  belongs_to  :schedule
  
  acts_as_audited

end