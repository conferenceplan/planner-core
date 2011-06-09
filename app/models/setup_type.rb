class SetupType < ActiveRecord::Base
  
  THEATRE = "Theatre"
  
  has_many :programme_items
  has_many :room_setups
  
  validates_uniqueness_of :name
end
