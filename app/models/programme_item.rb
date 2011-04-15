class ProgrammeItem < ActiveRecord::Base
  validates_presence_of :title
  validates_numericality_of :duration, :allow_nil => true
  validates_numericality_of :minimum_people, :allow_nil => true
  validates_numericality_of :maximum_people, :allow_nil => true
  has_many  :programme_item_assignments
  has_many  :people, :through => :programme_item_assignments
  
  acts_as_taggable
  # TODO - check if stream tagging is needed
  acts_as_taggable_on :streams
  
  belongs_to   :format 
  
  has_one :room_item_assignment # really we only use one anyway...
  has_one :room, :through => :room_item_assignment # TODO - check that this is still ok
  has_one :time_slot, :through => :room_item_assignment
  
  acts_as_audited
end
