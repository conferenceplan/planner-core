#
#
#
class PublishedProgrammeItem < ActiveRecord::Base
  attr_accessible :lock_version, :short_title, :title, :precis, :duration,
                  :pub_reference_number, :mobile_card_size, :audience_size, :participant_notes,
                  :format_id, :is_break, :start_offset, :visibility_id, :description,
                  :title_en, :title_fr, :title_pl, 
                  :short_title_en, :short_title_fr, :short_title_pl, 
                  :description_en, :description_fr, :description_pl

  translates :title, :description, :short_title, touch: true, fallbacks_for_empty_translations: true
  globalize_accessors

  has_enumerated :visibility

  audited :allow_mass_assignment => true

  # default sort children
  has_many   :children, :dependent => :destroy, :class_name => 'PublishedProgrammeItem', foreign_key: "parent_id" do
    def ordered_by_offset
      order("start_offset asc, title asc")
    end
  end
  
  belongs_to :parent,   :class_name => 'PublishedProgrammeItem' 

  has_many  :published_programme_item_assignments, :dependent => :destroy do #, :class_name => 'Published::ProgrammeItemAssignment'
    def role(r) # get the people with the given role
      where(['role_id = ?', r.id]).order('published_programme_item_assignments.sort_order asc')
    end
    def roles(r) # get the people with the given role
      where(['role_id in (?)', r]).order('published_programme_item_assignments.sort_order asc')
    end
  end
  has_many  :people, :through => :published_programme_item_assignments

  acts_as_taggable

  themed

  belongs_to :format 
  
  has_one :published_room_item_assignment, :dependent => :destroy
  has_one :published_room, :through => :published_room_item_assignment
  has_one :published_time_slot, :through => :published_room_item_assignment, :dependent => :destroy

  # The relates the published programme item back to the original programme item
  has_one :publication, :foreign_key => :published_id, :as => :published, :dependent => :destroy
  has_one :original, :through => :publication,
          :source => :original,
          :source_type => 'ProgrammeItem'

  # TODO - check
  has_many  :external_images, :as => :imageable,  :dependent => :delete_all do
    def use(u) # get the image for a given use (defined as a string)
      where(['external_images.use = ?', u])
    end
  end

  alias_attribute :images, :external_images
  alias_attribute :card_size, :mobile_card_size
  alias_attribute :precis, :description
  alias_attribute :requires_signup, :item_registerable

  def get_precis
    self[:precis]
  end

  def self.only_public
    where(visibility_id: Visibility['Public'].id)
  end

  def self.only_private
    where(visibility_id: Visibility['Private'].id)
  end

  def sorted_published_item_assignments(roles: [PersonItemRole['Participant'],PersonItemRole['Moderator'],PersonItemRole["OtherParticipant"]])
    assignments = []
    [PersonItemRole["Moderator"],PersonItemRole["Participant"],PersonItemRole["OtherParticipant"]].each do |role|
      assignments.concat published_programme_item_assignments.role(role).rank(:sort_order)
    end
    assignments
  end

  def duration
    _duration = read_attribute(:duration)
    _duration = self.parent.duration if self.parent && (_duration == nil || _duration == 0)
    _duration
  end

  def start_time
    if self.parent
      _start_time = self.parent.start_time
      _start_time = self.parent.start_time + self.start_offset.minutes if self.start_offset
    else
      _start_time = self.published_time_slot.start
    end
    _start_time
  end
  
  def end_time
    if self.parent
      _end_time = self.parent.published_time_slot.end
      offset = self.start_offset || 0
      _end_time = self.parent.published_time_slot.start + offset.minutes + self.duration.minutes if offset && self.duration
    else
      _end_time = self.published_time_slot.end
    end
    _end_time
  end

  def published_room_id
    published_room.id if published_room
  end


  def visibility_name
    visibility.name if visibility
  end

  def public?
    visibility == Visibility['Public']
  end

  def private?
    visibility == Visibility['Private']
  end

  def visible?(person: nil)
    if defined?(super)
      visible = super(person: person)
    else
      visible = false
    end

    visible = visible || public? || (
      private? && person.present? && (
        person.published_programme_items.include?(self) || 
        (self.children & person.published_programme_items).any?
      )
    )

    visible
  end

  def self.only_visible(person: nil)
    conditions = { visibility_id: Visibility['Public'].id }
    if person && person.published_programme_items.any?
      ids = person.published_programme_items.pluck(:id).uniq.compact.join(', ')
      conditions = "published_programme_items.visibility_id = '#{Visibility['Public'].id}' \
      OR published_programme_items.id in (#{ids})" if ids.present?
    end
    where(conditions)
  end
  
end
