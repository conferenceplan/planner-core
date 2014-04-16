class RoomSetup < ActiveRecord::Base
  attr_accessible :lock_version, :capacity, :room_id, :setup_type_id
    
  belongs_to :setup_type
  belongs_to :room
  
  validates_uniqueness_of :setup_type_id, :scope => :room_id
end
