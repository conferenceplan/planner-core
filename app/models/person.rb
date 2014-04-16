class Person < ActiveRecord::Base
  attr_accessible :lock_version, :first_name, :last_name, :suffix, :language, :comments, :company, :job_title,
                  :invitestatus_id, :invitation_category_id, :acceptance_status_id

  validates_numericality_of :mailing_number, :allow_nil => true # TODO - set the deafilt to 0 in DB, or move to a separate table containing the mailing information

  # Put in audit for people
  audited :allow_mass_assignment => true

  has_many  :addresses
  
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
            :source_type => 'TimeSlot'
  
  has_many  :excluded_items, :through => :exclusions,
            :source => :excludable,
            :source_type => "ProgrammeItem" 
  
  #
  has_many  :programmeItemAssignments
  has_many  :programmeItems, :through => :programmeItemAssignments, :include => [:time_slot, :room], :order => 'time_slots.start'
  
  has_many  :publishedProgrammeItemAssignments
  has_many  :published_programme_items, :through => :publishedProgrammeItemAssignments

  has_one   :registrationDetail, :dependent => :delete
  has_one   :survey_respondent
  has_enumerated :invitestatus, :class_name => 'InviteStatus'

  has_one   :survey_copy_status

  belongs_to  :invitation_category
  has_enumerated :acceptance_status, :class_name => 'AcceptanceStatus'
  
  #
  has_many  :person_mailing_assignments
  has_many  :mailings, :through => :person_mailing_assignments
  has_many  :mail_histories, :through => :person_mailing_assignments
  
  #
  acts_as_taggable
  
  # named_scope :by_last_name, :order => "last_name ASC"
  def by_last_name
    order("ast_name ASC")
  end
  
  #
  has_one  :pseudonym
  accepts_nested_attributes_for :pseudonym
  
  has_one :bio_image, :dependent => :delete
  
  has_one :edited_bio, :dependent => :delete
  accepts_nested_attributes_for :edited_bio
  
  has_one :available_date, :dependent => :delete
  accepts_nested_attributes_for :available_date
  
  has_one :peoplesource, :dependent => :delete
  has_one :datasource, :through => :peoplesource

  before_destroy :check_if_assigned

  # check that the person has not been assigned to program items, if they have then return an error and do not delete
  def check_if_assigned
    if programmeItemAssignments.size > 0
      raise 'Can not delete a person that has been assigned to programme items'
    end
  end

  def key
    if survey_respondent
      return survey_respondent.key
    else
      return 'n/a'
    end
  end

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
  
  def getFullName()
    [self.first_name,self.last_name,self.suffix].compact.join(' ')
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
        name = [self.pseudonym.first_name,self.pseudonym.last_name,self.pseudonym.suffix].compact.join(' ')
        if (name =~ /^\s*$/)
           name = [self.first_name,self.last_name,self.suffix].compact.join(' ')
        end
        return name.rstrip
    else
        return [self.first_name,self.last_name,self.suffix].compact.join(' ').rstrip
    end
  end
  
  def pubFirstName
    return self.pseudonym.first_name if (self.pseudonym != nil) && !(self.pseudonym.first_name.empty? && self.pseudonym.first_name.empty?)
    
    return first_name
  end

  def pubLastName
    return self.pseudonym.last_name if (self.pseudonym != nil) && !(self.pseudonym.last_name.empty? && self.pseudonym.last_name.empty?)
    
    return last_name
  end
  
  def pubSuffix
    return self.pseudonym.suffix if (self.pseudonym != nil) && !(self.pseudonym.suffix.empty? && self.pseudonym.suffix.empty?)
    
    return suffix
  end
  
  def GetSurveyBio
    response = SurveyResponse.first :joins => {:survey_respondent_detail => {:survey_respondent => :person}}, :conditions => {:isbio => true, :people => {:id => id}}
    
    if response
      return response.response
    else
      return ''
    end
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
  
  def UpdateIfPendingPersonDifferent(pending_id,updateAddressFlag,updateNameFlag,newRegistrationDetail)
    
    pendingImportPerson = PendingImportPerson.find(pending_id)
    postalAddresses = self.postal_addresses
    emailAddresses = self.email_addresses 
    
    myRegistrationDetail = self.registrationDetail
    
    
    savePendingStatus = nil
    # figure out if anything different first

    # see if need address update
    addressSame = false
    defaultAddress = nil
    if ((pendingImportPerson.addressNil? == true) && (self.postal_addresses.length() == 0))
      addressSame = true
    else
       self.postal_addresses.each do |matchaddress|
         if (pendingImportPerson.addressMatch?(matchaddress))
            addressSame = true
         end
         if (matchaddress.isdefault = true)
           defaultAddress = matchaddress
         end
     end
   end
   
    if (addressSame == false)
         pendingImportPerson.pendingtype = PendingType.find_by_name("PossibleAddressUpdate")
    end
   
    #see if need email update
    emailSame = false
    defaultEmail = nil
    if ((pendingImportPerson.emailNil? == true) && (self.email_addresses.length() == 0))
         emailSame = true
    else
      self.email_addresses.each do |matchaddress|
          if (pendingImportPerson.email == matchaddress.email)
             emailSame = true
          end #if
          if (matchaddress.isdefault == true)
            defaultEmail = matchaddress
          end
      end #each person
    end
    
    if (emailSame == false)
       pendingImportPerson.pendingtype = PendingType.find_by_name("PossibleAddressUpdate")
    end
    
    # check if name is same
    nameSame = false    
    if (self.last_name == pendingImportPerson.last_name && self.first_name == pendingImportPerson.first_name && self.suffix == pendingImportPerson.suffix)
      nameSame = true
    end
    
    if (nameSame == false)
      pendingImportPerson.pendingtype = PendingType.find_by_name("PossibleNameUpdate")
    end
    
    newRegistration = false
    if ((myRegistrationDetail == nil) && (newRegistrationDetail != nil))
      newRegistration = true
    end

    # see if we can update or just want to save in pending - return false if
    # saving in pending
    forceSaveAsPending = false
    if (nameSame == false)
      # don't update if the name does not match and an address doesn't match
      # could be an input file problem
      if (emailSame == false || addressSame == false)
        savePendingStatus = pendingImportPerson.pendingtype
        return savePendingStatus
        # if name is different, but we are not auto updating names, just return false to
        # save in pending
      elsif (updateNameFlag == 'review')
        savePendingStatus = pendingImportPerson.pendingtype
        return savePendingStatus
      end
    else
      # don't need to update, can just delete pending since it is the same as 
      # what we have
      if (emailSame == true && addressSame == true && newRegistration == false)
        return nil
      else
        if (emailSame == false || addressSame == false)
          # don't update if we are reviewing address and no reg change - save to pending
          if (updateAddressFlag == 'review')
             if (newRegistration == false)
               savePendingStatus = pendingImportPerson.pendingtype
               return savePendingStatus          
             else
               # force save to pending if reg change and address change
               forceSaveAsPending = true
             end
          end
        end
      end
    end

    # if we get here, there is something to update, but we only do record updates
    # from the primary datasource - there is too much complexity to manage
    # updates from multiple sources.Generally, the primary source is registration
    # and since ultimately, everyone should be in registration, we should not
    # need other updates.Other sources are for acquiring contact info before
    # people are registered and should not need updating
    if (pendingImportPerson.datasource.primary == false)
      savePendingStatus = pendingImportPerson.pendingtype
      return savePendingStatus
    end
    
    # check if new address, and if so, figure out if want to save
    # it as alternate or default
    newPostalAddress = false
    setAddressDefault = false
    if (addressSame == false)
        if (updateAddressFlag == 'auto')
          # update default address
          newPostalAddress = true
          setAddressDefault = true
        elsif (updateAddressFlag == 'alternate')
          #add alternate Address if already have default
          newPostalAddress = true
          # no default, go ahead and use this as default
          if (defaultAddress == nil)
            setAddressDefault = true
          end
        end
    end
    
      
    # check if new address, and if so, figure out if want to save
    # it as alternate or default
    newEmailAddress = false
    setEmailDefault = false
    if (emailSame == false)
      if (pendingImportPerson.datasource.primary == true)
        if (updateAddressFlag == 'auto')
          # update default address
          newEmailAddress = true
          setEmailDefault = true
        elsif (updateAddressFlag == 'alternate')
          #add alternate Address
          newEmailAddress = true
          # if no default, go ahead and use this a default
          if (defaultEmail == nil)
            setEmailDefault = true
          end
        end
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
                                 :phone => pendingImportPerson.phone,
                                 :isdefault => setAddressDefault)
      if ((defaultAddress != nil) && (setAddressDefault == true))
          defaultAddress.isdefault = false
          defaultAddress.save
      end
   end
      
   # the person may have previously not had a registration number
   newRegistration = false
   if ((myRegistrationDetail == nil) && (newRegistrationDetail != nil))
   
      self.registrationDetail = newRegistrationDetail
      newRegistration = true
   end
   
   # we have a new email address, so create one
   if (newEmailAddress == true)
      self.email_addresses.new(:email => pendingImportPerson.email,
                                 :isdefault => setEmailDefault)
      if ((defaultEmail != nil) && (setEmailDefault == true))
          defaultEmail.isdefault = false
          defaultEmail.save
      end
   end
      
   # save new addresses
   if (forceSaveAsPending == false)
     if (pendingImportPerson.datasource.primary == true)
        if (newEmailAddress == true || newPostalAddress == true || newRegistration )
          self.save
        end
     end
   end
      
   # update successful
   if (forceSaveAsPending == true)
     savePendingStatus = pendingImportPerson.pendingtype
     return savePendingStatus
   else
     return nil
   end
   
  end
  
  def GetExcludedTimesGroup
   excludedGroup = nil
   if (self.excluded_periods)    
     excludedTimes = self.excluded_periods
     # we need to figure out if we have daily repeating exclusions
     excludedGroup = {}
     @inExcludedGroup = {}
     self.excluded_periods.each do |excluded|
       next if (@inExcludedGroup.has_key?( excluded))
         
       excludedList = [excluded]
       excludedGroup[excluded] = excludedList
       @inExcludedGroup[excluded] = 1
       excludedTimes.each do |excluded1|
           if ((excluded.start.hour == excluded1.start.hour) and (excluded.start.min == excluded1.start.min) and (excluded.start.day != excluded1.start.day))
              excludedGroup[excluded] << excluded1
              @inExcludedGroup[excluded1] = 1
           end
       end
     end
   end
   return excludedGroup
 end
 
end
