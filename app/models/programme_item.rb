class ProgrammeItem < ActiveRecord::Base
  attr_accessible :lock_version, :short_title, :title, :precis, :duration, :minimum_people, :maximum_people, :item_notes, :print,
                  :pub_reference_number, :mobile_card_size, :audience_size, :participant_notes,
                  :setup_type_id, :format_id, :short_precis

  audited :allow_mass_assignment => true
  acts_as_taggable
  
  validates_presence_of :title
  validates_numericality_of :duration, :allow_nil => true
  validates_numericality_of :minimum_people, :allow_nil => true
  validates_numericality_of :maximum_people, :allow_nil => true
  
  # TODO - add expected audience size
  
  has_many  :programme_item_assignments, :dependent => :delete_all
  has_many  :people, :through => :programme_item_assignments
  
  has_many :equipment_needs, :dependent => :delete_all
  has_many :equipment_types, :through => :equipment_needs
  
  belongs_to :setup_type
 
  belongs_to :format 
  
  has_one :room_item_assignment, :dependent => :delete # really we only use one anyway...
  has_one :room, :through => :room_item_assignment #
  has_one :time_slot, :through => :room_item_assignment

  has_many :excluded_items_survey_maps, :dependent => :delete_all
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

end
