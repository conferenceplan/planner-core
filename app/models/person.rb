class Person < ActiveRecord::Base
  include Planner::ImageUrlGenerator
  attr_accessible :lock_version, :first_name, :last_name, :suffix, :language, :comments, :company, :job_title,
                  :pseudonym_attributes, :acceptance_status_id, :invitestatus_id, :invitation_category_id,
                  :postal_addresses_attributes, :email_addresses_attributes, :phone_numbers_attributes, :registrationDetail_attributes,
                  :prefix
                  
  attr_accessor :details

  acts_as_taggable

  has_contact_info
  
  # Put in audit for people
  audited :allow_mass_assignment => true

  has_many  :relationships, :dependent => :delete_all

  has_many  :related_people, :through => :relationships,
            :source => :relatable,
            :source_type => 'Person'

  has_one :pseudonym
  has_one :bio_image, :dependent => :delete
  alias_attribute :image, :bio_image

  has_one :edited_bio, :dependent => :delete
  
  has_one :peoplesource, :dependent => :delete
  has_one :datasource, :through => :peoplesource

  before_destroy :check_if_assigned

  accepts_nested_attributes_for :pseudonym, :edited_bio

  # named_scope :by_last_name, :order => "last_name ASC"
  def by_last_name
    order("last_name ASC")
  end
  
  # ----------------------------------------------------------------------------------------------
  #
  # Conference specific data - need to change so that the access is scoped by conference id
  #
  has_one :available_date, :dependent => :delete
  accepts_nested_attributes_for :available_date

  has_one :person_constraints, :dependent => :delete # THis is the max items per day & conference

  has_many  :exclusions, :dependent => :delete_all
  
  has_many  :excluded_people, :through => :exclusions, 
            :source => :excludable,
            :source_type => 'Person' do
              def find_by_source(s)
                where(['source = ?', s])
              end
            end
  
  has_many  :excluded_periods, :through => :exclusions,
            :source => :excludable,
            :source_type => 'TimeSlot' do
              def find_by_source(s)
                where(['source = ?', s])
              end
            end
  
  has_many  :excluded_items, :through => :exclusions,
            :source => :excludable,
            :source_type => "ProgrammeItem" do
              def find_by_source(s)
                where(['source = ?', s])
              end
            end
  
  has_many  :programmeItemAssignments, :dependent => :destroy
  has_many  :programmeItems, :through => :programmeItemAssignments
  
  has_many  :publishedProgrammeItemAssignments #, :dependent => :destroy # NOTE - we let the publish mechanism to the destroy so that the update service knows what is happening
  has_many  :published_programme_items, :through => :publishedProgrammeItemAssignments

  has_one   :registrationDetail, :dependent => :delete
  accepts_nested_attributes_for :registrationDetail

  has_one   :survey_respondent, :dependent => :destroy

  has_many  :person_mailing_assignments
  has_many  :mailings, :through => :person_mailing_assignments
  has_many  :mail_histories #, :through => :person_mailing_assignments
  
  belongs_to  :dep_invitation_category, :foreign_key => 'invitation_category_id', :class_name => "InvitationCategory" # TODO - SCOPE
  
  has_one      :person_con_state, dependent: :destroy

  ## Scopes ##
  def self.attendees
    people = joins(:registrationDetail).where("registration_details.registered is true")
    people.uniq
  end

  def self.speakers
    speakers = joins(:programmeItemAssignments)
    speakers.uniq
  end

  def self.participants
    where([
      "people.id in (:assigned_people) OR people.id in (:registered_people)", 
      { assigned_people: Person.speakers.pluck(:id), registered_people: Person.attendees.pluck(:id) }
    ]).uniq
  end
  
  # ----------------------------------------------------------------------------------------------


  def acceptance_status_id=(arg)
    self.person_con_state = PersonConState.new if !self.person_con_state
    self.person_con_state.acceptance_status_id = arg
    self.person_con_state.save! if self.id && self.id > 0
  end
  
  def invitestatus_id=(arg)
    self.person_con_state = PersonConState.new if !self.person_con_state
    self.person_con_state.invitestatus_id = arg
    self.person_con_state.save! if self.id && self.id > 0
  end
  
  def invitation_category_id=(arg)
    self.person_con_state = PersonConState.new if !self.person_con_state
    self.person_con_state.invitation_category_id = arg
    self.person_con_state.save! if self.id && self.id > 0
  end
  
  def acceptance_status
    if person_con_state
      person_con_state.acceptance_status
    else
      nil
    end
  end
  
  def acceptance_state
    if person_con_state && person_con_state.acceptance_status.present?
      person_con_state.acceptance_status.name
    else
      nil
    end
  end
  
  def acceptance_status=(arg)
    self.person_con_state = PersonConState.new if !self.person_con_state
    self.person_con_state.acceptance_status = arg
    self.person_con_state.save! if self.id && self.id > 0
  end

  def invitestatus
    if person_con_state
      person_con_state.invitestatus
    else
      nil
    end
  end

  def invite_state
    if person_con_state && person_con_state.invitestatus.present?
      person_con_state.invitestatus.name
    else
      nil
    end
  end
  
  def invitestatus=(arg)
    self.person_con_state = PersonConState.new if !self.person_con_state
    self.person_con_state.invitestatus = arg
    self.person_con_state.save! if self.id && self.id > 0
  end  
  
  def invitation_category
    if person_con_state
      person_con_state.invitation_category
    else
      nil
    end
  end  
  
  def invitation_category=(arg)
    self.person_con_state = PersonConState.new if !self.person_con_state
    self.person_con_state.invitation_category = arg
    self.person_con_state.save! if self.id && self.id > 0
  end  
  
  # check that the person has not been assigned to program items, if they have then return an error and do not delete
  def check_if_assigned
    if (ProgrammeItemAssignment.unscoped.where(person_id: id).count > 0) || (PublishedProgrammeItemAssignment.unscoped.where(person_id: id).count > 0)
      raise "You cannot delete a person that has been assigned to program items (either in this event or in another one of your events). If you want to delete this person, you need to first remove all of this person's speaking assignments in all relevant events, and make sure those removals are published."
    end
  end

  def key
    if survey_respondent
      return survey_respondent.key
    else
      return 'n/a'
    end
  end

  # TODO - scope for conference
  def bio
    edited_bio ? edited_bio.bio : ""
  end

  def twitterinfo
    edited_bio ? edited_bio.twitterinfo : ""
  end

  def website
    edited_bio ? edited_bio.website : ""
  end

  def facebook
    edited_bio ? edited_bio.facebook : ""
  end
  
  def linkedin
    edited_bio ? edited_bio.linkedin : ""
  end
  

  def getFullName()
    full_name
  end
  
  def full_name()
    [self.prefix, self.first_name,self.last_name,self.suffix].compact.join(' ').strip
  end

  def real_name
    name = {}
    name[:prefix] = self.prefix
    name[:first] = self.first_name
    name[:last] = self.last_name
    name[:suffix] = self.suffix

    name
  end

  def publication_name
    name = {}

    if self.pseudonym.present?
      name[:prefix] = self.pseudonym.prefix
      name[:first] = self.pseudonym.first_name
      name[:last] = self.pseudonym.last_name
      name[:suffix] = self.pseudonym.suffix
    else
      name = real_name
    end

    name
  end

  def full_publication_name
    getFullPublicationName
  end

  def getFullPublicationName
   # if we set the pseudonym in people table, use that
   if (self.pseudonym != nil)
        name = [self.pseudonym.prefix, self.pseudonym.first_name,self.pseudonym.last_name,self.pseudonym.suffix].compact.join(' ')
        if (name =~ /^\s*$/)
           name = [self.prefix, self.first_name,self.last_name,self.suffix].compact.join(' ')
        end
        return name.strip
    else
        return [self.prefix, self.first_name,self.last_name,self.suffix].compact.join(' ').strip
    end
  end
  
  def getFullPublicationNameSansPrefix
   # if we set the pseudonym in people table, use that
   if (self.pseudonym != nil)
        name = [self.pseudonym.first_name,self.pseudonym.last_name,self.pseudonym.suffix].compact.join(' ')
        if (name =~ /^\s*$/)
           name = [self.first_name,self.last_name,self.suffix].compact.join(' ')
        end
        return name.strip
    else
        return [self.first_name,self.last_name,self.suffix].compact.join(' ').strip
    end
  end
  
  def getFullPublicationFirstAndLastName
   # if we set the pseudonym in people table, use that
   if (self.pseudonym != nil)
        name = [self.pseudonym.first_name,self.pseudonym.last_name].compact.join(' ')
        if (name =~ /^\s*$/)
           name = [self.first_name,self.last_name].compact.join(' ')
        end
        return name.strip
    else
        return [self.first_name,self.last_name].compact.join(' ').strip
    end
  end
  
  def pubPrefix
    return self.pseudonym.prefix if (self.pseudonym != nil) && !self.pseudonym.prefix.blank?
    
    return prefix ? prefix : ''
  end

  def pubFirstName
    return self.pseudonym.first_name if (self.pseudonym != nil) && 
      (!self.pseudonym.last_name.blank? || !self.pseudonym.first_name.blank?)
    
    return first_name
  end

  def pubLastName
    return self.pseudonym.last_name if (self.pseudonym != nil) && 
      (!self.pseudonym.last_name.blank? || !self.pseudonym.first_name.blank?)
    
    return last_name
  end
  
  def pubSuffix
    return self.pseudonym.suffix if (self.pseudonym != nil) && !self.pseudonym.suffix.blank?
    
    return suffix
  end
  
  def GetSurveyBio
    response = SurveyService.getSurveyBio id # TODO - there can be more than one survey with a BIO
    
    if response
      return response.response
    else
      return ''
    end
  end
  
  def is_speaker?
    published_programme_items && published_programme_items.any?
  end

  def public_image_url scale: 1, version: :standard
    person_image(image, scale: scale, version: version)
  end

  def viewable_by_public?
    viewable = has_public_assigned_items?
    if !viewable && registrationDetail && registrationDetail.registered
      viewable = registrationDetail.can_share
    end

    viewable
  end

  def has_public_assigned_items?
    publishedProgrammeItemAssignments.with_public_items.any?
  end

  def self.with_public_assigned_items
    joins(:published_programme_items).
    where(
      published_programme_items: {
        visibility_id: Visibility['Public']
      }
    ).uniq
  end

  def is_assigned_to_items_with_person?(person)
    published_programme_items.any? && person.published_programme_items.any? && 
    (published_programme_items & person.published_programme_items).any?
  end

  def participates_in_current_event?
    linked = publishedProgrammeItemAssignments.any? || 
    (registrationDetail.present? && registrationDetail.registered)

    linked
  end

  def relevant_to_current_event?
    linked = participates_in_current_event? || person_con_state.present? || 
    mailings.any? || survey_respondent.present?

    linked
  end

end
