class TimeSlot < ActiveRecord::Base

  belongs_to  :schedule
  belongs_to  :room
  
  acts_as_audited :parent => :room

end