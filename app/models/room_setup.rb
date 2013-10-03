class RoomSetup < ActiveRecord::Base
  
  belongs_to :setup_type
  belongs_to :room
  
  validates_uniqueness_of :setup_type_id, :scope => :room_id
end
