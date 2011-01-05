class Person < ActiveRecord::Base
  validates_numericality_of :mailing_number, :allow_nil => true # TODO - set the deafilt to 0 in DB, or move to a separate table containing the mailing information

  has_many  :addresses
  
  has_many  :postal_addresses, :through => :addresses,
            :source => :addressable, 
            :source_type => 'PostalAddress'
  
  has_many  :email_addresses, :through => :addresses, 
            :source => :addressable, 
            :source_type => 'EmailAddress'

  accepts_nested_attributes_for :postal_addresses, :email_addresses

  has_many  :relationships
  
  has_many  :related_people, :through => :relationships,
            :source => :relatable,
            :source_type => 'Person'

  has_many  :exclusions
  
  has_many  :excluded_people, :through => :exclusions, 
            :source => :excludable,
            :source_type => 'Person'
  
  has_many  :excluded_periods, :through => :exclusions,
            :source => :excludable,
            :source_type => 'Period'
  
  has_many  :excluded_items, :through => :exclusions,
            :source => :excludable,
            :source_type => "ProgrammeItem" 
  
  # TODO - check this
  has_many  :programmeItemAssignments
  has_many  :programmeItems, :through => :programmeItemAssignments

  has_one   :registrationDetail, :dependent => :delete
  has_one   :survey_respondent
  has_enumerated :invitestatus, :class_name => 'InviteStatus'

  belongs_to  :invitation_category
  has_enumerated :acceptance_status, :class_name => 'AcceptanceStatus'
  
  #
  acts_as_taggable
  acts_as_taggable_on :activities
  
  #
  has_one  :pseudonym
  accepts_nested_attributes_for :pseudonym
    
  def GetFullName()
      name = ""
      if (self.first_name != nil)
        name = self.first_name
      end
      if (self.last_name != nil)
        name = name + " " + self.last_name
      end
      if (self.suffix != nil)
         name = self.first_name + " " + self.last_name
      end
      if (self.suffix != nil)
        name = name + self.suffix
      end
      return name
  end
  
  def getDefaultPostalAddress()
    possibleAddresses = postal_addresses
    theAddress = nil
    if possibleAddresses
      possibleAddresses.each do |addr| 
        if addr.isdefault
          theAddress = email
        else # if the email is empty we want to take the first one (unless there is a default)
          if theAddress == nil
            theAddress = addr
          end
        end
      end
    end
    return theAddress
  end

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
  
  def removePostalAddress(address)
    # TODO - change to handle any address type
     postal_addresses.delete(address) # remove it from the person
     # and then make sure that it is not used by another person
     if (! addresses.find(:all, :conditions =>  ["addressable_id = ? and person_id != ?", address, @id] ) )
       address.destroy
     end
  end
  
  def removeEmailAddress(address)
    # TODO - change to handle any address type
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
  
  def UpdateIfPendingPersonDifferent(pending_id)
  pendingImportPerson = PendingImportPerson.find(pending_id)
    postalAddresses = self.postal_addresses
    emailAddresses = self.email_addresses
    myRegistrationDetail = self.registrationDetail
    
    if ((myRegistrationDetail == nil) && (pendingImportPerson.registration_number) && pendingImportPerson.registration_number != "")
      myRegistrationDetail = new RegistrationDetail(:registration_number => pendingImportPerson.registration_number,
                                                    :registration_type => pendingImportPerson.registration_type)
      self.registrationDetail = myRegistrationDetail
    end
    # we can only automatically update addresses from pendingImportPerson
    # if we have 1 email and postal address in our database
    # if we have more than 1, we can't tell which one to update
    # and require user intervention
    if postalAddresses.size <= 1 && emailAddresses.size <= 1
      newPostalAddress = true
      newEmailAddress = true
      # check if postal address in database is different - if so, remove from database
      if (postalAddresses.size == 1)
        address = postalAddresses[0]
      
        if ((pendingImportPerson.line1 != address.line1) ||
            (pendingImportPerson.line2 != address.line2) ||
            (pendingImportPerson.city != address.city ) ||
            (pendingImportPerson.country != address.country) ||
            (pendingImportPerson.postcode != address.postcode) ||
            (pendingImportPerson.phone != address.phone))
            self.removePostalAddress(address)  
        else
            newPostalAddress = false
        end
      end
      # check if email address is different - if so, remove email from database
      if (emailAddresses.size == 1)
        eaddress = emailAddresses[0]
        if (pendingImportPerson.email != eaddress.email)
          self.removeEmailAddress(eaddress)
        else
          newEmailAddress = false
        end
      end
      # we have a new postal address, so create one
      if (newPostalAddress == true)
           self.postal_addresses.new(:line1 => pendingImportPerson.line1,
                                     :line2 => pendingImportPerson.line2,
                                     :city  => pendingImportPerson.city,
                                     :postcode => pendingImportPerson.postcode,
                                     :state => pendingImportPerson.state,
                                     :country => pendingImportPerson.country,
                                     :phone => pendingImportPerson.phone)
      end
      # the person may have previously not had a registration number
      newRegistration = false
      if ((myRegistrationDetail == nil) && (pendingImportPerson.registration_number) && pendingImportPerson.registration_number != "")
         myRegistrationDetail = new RegistrationDetail(:registration_number => pendingImportPerson.registration_number,
                                                       :registration_type => pendingImportPerson.registration_type)
         self.registrationDetail = myRegistrationDetail
         newRegistration = true
      end
      # we have a new email address, so create one
      if (newEmailAddress == true)
        self.email_addresses.new(:email => pendingImportPerson.email)
      end
      
      # save new addresses
      if (newEmailAddress == true || newPostalAddress == true || newRegistration)
        self.save
      end
      # update successful
      return true
    else
      # can't update since we have multiple addresses
      return false
    end
  end
 
end
