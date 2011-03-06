class ProgrammeItem < ActiveRecord::Base
  validates_presence_of :title
  validates_numericality_of :duration, :allow_nil => true
  validates_numericality_of :minimum_people, :allow_nil => true
  validates_numericality_of :maximum_people, :allow_nil => true
  has_many  :programme_item_assignments
  has_many  :people, :through => :programme_item_assignments
  
  #
  acts_as_taggable
  acts_as_taggable_on :streams
  
  # TODO: Add event substitutions, people that can be added to an event
  # if person is removed from event then user is asked if the person should be added to subs
  
  belongs_to   :room
  belongs_to   :format 
  has_one   :time_slot
  
  acts_as_audited :parent => :room
end
