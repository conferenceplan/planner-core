class TimeSlot < ActiveRecord::Base

  belongs_to  :schedule
  belongs_to  :room
  
end