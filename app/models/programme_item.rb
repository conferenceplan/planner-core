
class ProgrammeItem < ActiveRecord::Base
  translates :title, :description, :short_title, :short_description, touch: true
  globalize_accessors

  PERMITTED_PARAMS = 
    self.globalize_attribute_names +
    [
      :lock_version, :duration, :minimum_people, :maximum_people, :item_notes, 
      :pub_reference_number, :mobile_card_size, :audience_size, 
      :participant_notes, :setup_type_id, :format_id, :parent_id, :is_break, 
      :start_offset, :visibility_id
    ]
  attr_accessible *PERMITTED_PARAMS

  has_enumerated :visibility
  
  audited :allow_mass_assignment => true
  acts_as_taggable

  themed
  
  # default sort children?
  has_many   :children, :dependent => :destroy, :class_name => 'ProgrammeItem', foreign_key: "parent_id"
  belongs_to :parent,   :class_name => 'ProgrammeItem' 
  
  validates_presence_of :title
  validates_numericality_of :duration, :allow_nil => true
  validates_numericality_of :minimum_people, :allow_nil => true
  validates_numericality_of :maximum_people, :allow_nil => true
  
  has_many  :programme_item_assignments, :dependent => :destroy
  has_many  :people, :through => :programme_item_assignments
  
  has_many :equipment_needs, :dependent => :destroy
  has_many :equipment_types, :through => :equipment_needs
  
  belongs_to :setup_type
 
  belongs_to :format 
  
  has_one :room_item_assignment, :dependent => :destroy # really we only use one anyway...
  has_one :room, :through => :room_item_assignment #
  has_one :time_slot, :through => :room_item_assignment

  has_many :excluded_items_survey_maps, :dependent => :destroy
  # has_many :mapped_survey_questions, :through => :excluded_items_survey_maps
  
  # The relates the published programme item back to the original programme item
  has_one :publication, :foreign_key => :original_id, :as => :original, :dependent => :destroy
  has_one :published, :through => :publication,
          :source => :published,
          :source_type => 'PublishedProgrammeItem'

  #
  has_many  :external_images, :as => :imageable,  :dependent => :delete_all do
    def use(u) # get the image for a given use (defined as a string)
      where(['external_images.use = ?', u])
    end
  end

  alias_attribute :precis, :description
  alias_attribute :requires_signup, :item_registerable

  before_save :check_parent, :sanitize_for_break

  def self.permitted_params
    PERMITTED_PARAMS
  end

  def get_precis
    self[:precis]
  end

  def start_time
    if self.parent && self.parent.time_slot
      _start_time = self.parent.time_slot.start
      _start_time = self.parent.time_slot.start + self.start_offset.minutes if self.start_offset
    else
      _start_time = self.time_slot ? self.time_slot.start : nil
    end
    _start_time
  end
  
  def end_time
    if self.parent && self.parent.time_slot
      _end_time = self.parent.time_slot.end
      offset = self.start_offset || 0
      _end_time = self.parent.time_slot.start + offset.minutes + self.duration.minutes if offset && self.duration
    else
      _end_time = self.time_slot ? self.time_slot.end : nil
    end
    _end_time
  end
  
  #
  # Update the item assignments for the given role
  #
  def update_assignments(updates)
    update_ids = updates.collect{|u| u.id }.compact

    # find the assignments to remove
    del_candidates = programme_item_assignments.
                          where(["role_id in (?)",[PersonItemRole['Invisible'].id, PersonItemRole['Participant'].id,PersonItemRole['OtherParticipant'].id,PersonItemRole['Moderator'].id,PersonItemRole['Reserved'].id]]).
                          to_a.
                          keep_if{|c| !update_ids.include?(c.id)}
    
    # find the assignments to create & update
    create_candidates = updates.map{|u| u.id == nil ? u : nil }.compact
    update_candidates = updates.map{|u| u.id != nil ? u : nil }.compact

    # We may not want to delete since the item may be moved to another role ....
    if del_candidates
      self.touch if !self.new_record?
      self.save
    end
    del_candidates.each do |c|
      c.destroy
    end
    
    create_candidates.each do |c|
      assignment = programme_item_assignments.create({role_id: c.role_id, person_id: c.person_id})
      assignment.sort_order_position = c.sort_order_position if c.sort_order_position
      assignment.save
    end

    update_candidates.each do |u|
      assignment = u
      assignment.save
    end
  end

  def self.deep_clone_members(keep_room_assignment = true, within_conference = true)
    members = [
      :programme_item_assignments #, :parent
    ]

    members << {:children => :programme_item_assignments} if within_conference
    members << :taggings if within_conference
    members << :themes if within_conference
    members << {room_item_assignment: :time_slot} if keep_room_assignment

    members
  end

  def visibility_name
    visibility.name if visibility
  end


  def self.scheduled
    joins(:room_item_assignment).uniq
  end

  def self.unscheduled
    where(["parent_id is null and id not in (?)", ProgrammeItem.scheduled.pluck(:id)])
  end

  def self.child_items
    where("parent_id is not null")
  end
  

  def public?
    visibility == Visibility['Public']
  end

  def private?
    visibility == Visibility['Private']
  end

  def visibility_none?
    visibility == Visibility['None']
  end

  protected

  def sanitize_for_break
    if self.is_break
      self.parent_id = nil # ensure no parent/child
    end
  end
  
  def check_parent
    raise "An item can't be a parent of itself." if self.id && (self.id == self.parent_id)
    raise "You can't set an item as a child of a child." if self.id && self.parent_id && self.parent.parent_id
    raise "You can't set an parent for an item that is also a parent." if self.id && self.parent_id && (self.children.size > 0)
    raise "Item can't be a child of a break." if self.id && self.parent_id && self.parent.is_break
    raise "A break can't have a parent." if self.id && self.parent_id && self.is_break
    raise "A break can't be a parent." if self.id && (self.children.size > 0) && self.is_break
  end


end

# TODO - create a clone function
# Should create with a new name (copy of)
# keep the description
# do not keep the time/room/people
