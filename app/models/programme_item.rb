class ProgrammeItem < ActiveRecord::Base
  validates_presence_of :title
  validates_numericality_of :duration, :allow_nil => true
  validates_numericality_of :minimum_people, :allow_nil => true
  validates_numericality_of :maximum_people, :allow_nil => true
  has_many  :programme_item_assignments
  has_many  :people, :through => :programme_item_assignments
  
  has_many :equipment_needs
  has_many :equipment_types, :through => :equipment_needs
  
  acts_as_taggable

  belongs_to :setup_type
 
  belongs_to   :format 
  
  has_one :room_item_assignment # really we only use one anyway...
  has_one :room, :through => :room_item_assignment #
  has_one :time_slot, :through => :room_item_assignment
  
  def start_day
    # change to selection
    if time_slot
      return time_slot.start.strftime('%A')
    else
      return Time.zone.parse(SITE_CONFIG[:conference][:start_date]).strftime('%A')
    end
  end

  def start_time
    if time_slot
      # correct format
      return time_slot.start.strftime('%H:%M')
    else
      return '09:00'
    end
  end
  
  has_many :excluded_items_survey_maps
  has_many :mapped_survey_questions, :through => :excluded_items_survey_maps
  
  # The relates the published programme item back to the original programme item
  has_one :publication, :foreign_key => :original_id, :as => :original, :dependent => :destroy
  has_one :published, :through => :publication,
          :source => :published,
          :source_type => 'PublishedProgrammeItem'
  
  acts_as_audited
end
