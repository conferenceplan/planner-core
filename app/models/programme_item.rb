class ProgrammeItem < ActiveRecord::Base
  attr_accessible :lock_version, :short_title, :title, :precis, :duration, :minimum_people, :maximum_people, :item_notes, :print,
                  :pub_reference_number, :mobile_card_size, :audience_size, :participant_notes,
                  :setup_type_id, :format_id, :short_precis, :parent_id, :is_break

  audited :allow_mass_assignment => true
  acts_as_taggable

  themed
  
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
      find(:all, :conditions => ['external_images.use = ?', u])
    end
  end

  before_save :check_parent, :sanitize_for_break
  
  #
  # Update the item assignments for the given role
  #
  def update_assignments(updates, role_id)
    update_ids = updates.collect{|u| u.id }.compact

    # find the assignments to remove
    del_candidates = programme_item_assignments.where({role_id: role_id}).keep_if{|c| !update_ids.include?(c.id)}
    
    # find the assignments to create & update
    create_candidates = updates.keep_if{|u| u.id == nil }
    update_candidates = updates.keep_if{|u| u.id > 0 }

    del_candidates.each do |c|
      c.delete
    end
    
    create_candidates.each do |c|
      assignment = programme_item_assignments.create({role_id: c.role_id, person_id: c.person_id})
      assignment.sort_order_position = c.sort_order
      assignment.save
    end

    update_candidates.each do |u|
      assignment = programme_item_assignments.create({role_id: role_id, person_id: c.person_id})
      assignment.sort_order_position = c.sort_order
      assignment.save
    end
  end

  protected
  
  def sanitize_for_break
    if self.is_break
      self.parent_id = nil # ensure no parent/child
      self.format_id = nil # no format

      # self.programme_item_assignments.destroy_all # ensure no people

      # self.room_item_assignment.destroy if self.room_item_assignment # ensure no room...
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
