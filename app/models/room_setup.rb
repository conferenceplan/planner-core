class RoomSetup < ActiveRecord::Base
  
  belongs_to :setup_types
  has_many :rooms
  
  validates_uniqueness_of :setup_type_id, :scope => :room_id
end
