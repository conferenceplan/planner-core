class Room < ActiveRecord::Base
  
  belongs_to  :venue
  has_many  :time_slots
  
end
