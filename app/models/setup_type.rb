class SetupType < ActiveRecord::Base
  attr_accessible :lock_version, :name, :description
    
  THEATRE = "Theatre"
  
  has_many :programme_items
  has_many :room_setups
  
  validates_uniqueness_of :name
  
  before_destroy :check_for_use

private

  def check_for_use
    if RoomSetup.where( :setup_type_id => id ).exists?
      raise "can not delete a setup that is being used"
    end
  end
end
