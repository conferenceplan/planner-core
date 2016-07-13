class Person < ActiveRecord::Base
  attr_accessible :lock_version, :first_name, :last_name, :suffix, :language, :comments, :company, :job_title,
                  :pseudonym_attributes, :acceptance_status_id, :invitestatus_id, :invitation_category_id,
                  :postal_addresses_attributes, :email_addresses_attributes, :phone_numbers_attributes, :registrationDetail_attributes,
                  :prefix
                  
  attr_accessor :details

  acts_as_taggable
  
  # Put in audit for people
  audited :allow_mass_assignment => true
  
  has_many  :addresses, :dependent => :delete_all
  
  has_many  :postal_addresses, :through => :addresses,
            :source => :addressable, 
            :source_type => 'PostalAddress'
  
  has_many  :email_addresses, :through => :addresses, 
            :source => :addressable, 
            :source_type => 'EmailAddress'

  has_many :phone_numbers, :through => :addresses,
            :source => :addressable,
            :source_type => 'PhoneNumber'

  accepts_nested_attributes_for :postal_addresses, :email_addresses, :phone_numbers

  has_many  :relationships, :dependent => :delete_all

  has_many  :related_people, :through => :relationships,
            :source => :relatable,
            :source_type => 'Person'

  has_one :pseudonym
  has_one :bio_image, :dependent => :delete
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
                find(:all, :conditions => ['source = ?', s])
              end
            end
  
  has_many  :excluded_periods, :through => :exclusions,
            :source => :excludable,
            :source_type => 'TimeSlot' do
              def find_by_source(s)
                find(:all, :conditions => ['source = ?', s])
              end
            end
  
  has_many  :excluded_items, :through => :exclusions,
            :source => :excludable,
            :source_type => "ProgrammeItem" do
              def find_by_source(s)
                find(:all, :conditions => ['source = ?', s])
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
  
  has_one      :person_con_state
  
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
  
  def getFullName()
    [self.prefix, self.first_name,self.last_name,self.suffix].compact.join(' ').strip
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
  
  def updatePhone(new_phone, phonetype)
    
    # first find the existing phone of the given type
    # if found update it
    # otherwise create a new instance
    phone = phone_numbers.detect { |ph| ph.phone_type == PhoneTypes[phonetype] }# findPhoneByType(phonetype)
    if phone
      phone.number = new_phone
      phone.save!
    else
      phone = self.phone_numbers.new :number => new_phone
      phone.number = new_phone
      phone.phone_type = PhoneTypes[phonetype]
      self.save!
    end
    
  end
  
  #
  #
  #
  def addressMatch?(new_line1, new_city, new_state, new_postcode, new_country)
    address = getDefaultPostalAddress()

    if address
      if ((address.line1 == new_line1) &&
         (address.city == new_city) &&
         (address.state == new_state) &&
         (address.postcode == new_postcode) &&
         (address.country == new_country))
         return true
      else
        return false
      end
    else
      return false
    end
  end
  
  #
  #
  #
  def emailMatch?(email)
    e = getDefaultEmail()
    
    return e ? e.email == email : false
  end

  def updateDefaultEmail(email)
    e = getDefaultEmail()
    if e
      e.isdefault = false
      e.save!
    end
 
    e = self.email_addresses.new :email => email, :isdefault => true 
   
    self.save!
  end

  #
  #
  #
  def updateDefaultAddress(new_line1, new_city, new_state, new_postcode, new_country)
    # We will create a new address object and make that the default (so the old one will no longer be used but will still be in the list)
    address = getDefaultPostalAddress
    
    if address
      address.isdefault = false
      address.save!
    end
    
    postalAddress = self.postal_addresses.new :line1 => new_line1, :city => new_city, :state => new_state, :postcode => new_postcode, :country => new_country, :isdefault => true 

    self.save!
  end

  #
  #
  #
  def replaceDefaultAddress(new_line1, new_line2, new_city, new_state, new_postcode, new_country, new_state_code, new_country_code)
    # We will create a new address object and make that the default (so the old one will no longer be used but will still be in the list)
    address = getDefaultPostalAddress
    
    if address
      address.line1 = new_line1
      address.line2 = new_line2
      address.city = new_city
      address.state = new_state if !new_state.blank?
      address.postcode = new_postcode
      address.country = new_country if !new_country.blank?
      address.state_code = new_state_code
      address.country_code = new_country_code
      address.save!
    else
      postalAddress = self.postal_addresses.create :line1 => new_line1, 
                                    :line2 => new_line2, 
                                    :city => new_city, 
                                    # :state => new_state, 
                                    :postcode => new_postcode, 
                                    # :country => new_country, 
                                    :state_code => new_state_code,
                                    :country_code => new_country_code,
                                    :isdefault => true 
      postalAddress.state = new_state if !new_state.blank?
      postalAddress.country = new_country if !new_country.blank?
      postalAddress.save
    end

    self.save!
    self
  end

  #
  #
  #
  def getDefaultPostalAddress()
    possibleAddresses = postal_addresses
    theAddress = nil
    if possibleAddresses
      possibleAddresses.each do |addr| 
        if addr.isdefault
          theAddress = addr
        else # if the address is empty we want to take the first one (unless there is a default)
          if theAddress == nil
            theAddress = addr
          end
        end
      end
    end
    return theAddress
  end

  #
  #
  #
  def getDefaultEmail()
    possibleEmails = email_addresses
    theEmail = nil
    if possibleEmails
      possibleEmails.each do |email| 
        if email.isdefault
          theEmail = email
        else # if the email is empty we want to take the first one (unless there is a default)
          if theEmail == nil
            theEmail = email
          end
        end
      end
    end
    return theEmail
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
    return self.pseudonym.first_name if (self.pseudonym != nil) && !self.pseudonym.first_name.blank?
    
    return first_name
  end

  def pubLastName
    return self.pseudonym.last_name if (self.pseudonym != nil) && !self.pseudonym.last_name.blank?
    
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
  
  def removePostalAddress(address)
     postal_addresses.delete(address) # remove it from the person
     # and then make sure that it is not used by another person
     if (! addresses.find(:all, :conditions =>  ["addressable_id = ? and person_id != ?", address, @id] ) )
       address.destroy
     end
  end
  
  def removeEmailAddress(address)
     email_addresses.delete(address) # remove it from the person
     # and then make sure that it is not used by another person
     if (! addresses.find(:all, :conditions =>  ["addressable_id = ? and person_id != ?", address, @id] ) )
       address.destroy
     end
  end

  def removeAllAddresses()
    # Get the addresses and if they are not reference by other people the get rid of them...
    postalAddresses = self.postal_addresses
    
    if (postalAddresses)
      postalAddresses.each do |address|
        self.removePostalAddress(address)
      end
    end
    emailAddresses = self.email_addresses
    if (emailAddresses)
      emailAddresses.each do |eaddress|
        self.removeEmailAddress(eaddress)
      end
    end
  end

  def is_speaker?
    published_programme_items && published_programme_items.any?
  end

end
