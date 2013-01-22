class Person < ActiveRecord::Base
  validates_numericality_of :mailing_number, :allow_nil => true # TODO - set the deafilt to 0 in DB, or move to a separate table containing the mailing information

  # Put in audit for people
  acts_as_audited

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
  has_many  :programmeItems, :through => :programmeItemAssignments

  has_one   :registrationDetail, :dependent => :delete
  has_one   :survey_respondent
  has_enumerated :invitestatus, :class_name => 'InviteStatus'

  has_one   :survey_copy_status

  belongs_to  :invitation_category
  has_enumerated :acceptance_status, :class_name => 'AcceptanceStatus'
  
  #
  acts_as_taggable
  
  named_scope :by_last_name, :order => "last_name ASC"
  
  #
  has_one  :pseudonym
  accepts_nested_attributes_for :pseudonym
  
  has_one :edited_bio, :dependent => :delete
  accepts_nested_attributes_for :edited_bio
  
  has_one :available_date, :dependent => :delete
  accepts_nested_attributes_for :available_date
  
  has_one :peoplesource, :dependent => :delete
  has_one :datasource, :through => :peoplesource
  
  def bio
    if edited_bio
      return edited_bio.bio
    else
      return ""
    end
  end

  def twitterinfo
    if edited_bio
      return edited_bio.twitterinfo
    else
      return ""
    end
  end

  def website
    if edited_bio
      return edited_bio.website
    else
      return ""
    end
  end

  def facebook
    if edited_bio
      return edited_bio.facebook
    else
      return ""
    end
  end
  
  def GetFullNameHelper(first_name,last_name,suffix)
      name = ""
      # set first name if it exists
      if (first_name != nil)
        name = first_name
      end
      
      # append last name if exits
      if (last_name != nil)
        # if there is a first name append with space
        if (name != "")
           name = name + " " + last_name
        else
          # no first name, don't put space in
          name = last_name
        end
      end
    
      # append suffix if it exits
      if (suffix != nil)
        name = name + " " + suffix
      end
      
      return name
  end
  
  def GetFullName()
      return GetFullNameHelper(self.first_name,self.last_name,self.suffix)
  end
  
  def findPhoneByType(phonetype)
    # go through the phones and see if any of them match the given phonetype
    # if they do then say so
    
    phone_numbers.each do |p|
      if p.phone_type == PhoneTypes[phonetype]
        return p
      end
    end
    
    return nil
  end
  
  def updatePhone(new_phone, phonetype)
    
    # first find the existing phone of the given type
    # if found update it
    # otherwise create a new instance
    phone = findPhoneByType(phonetype)
    if phone
      phone.number = new_phone
      phone.phone_type = PhoneTypes[phonetype]
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
    
    return e == email
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
  
  def hasSurvey?
    return self.survey_respondent != nil ? self.survey_respondent.submitted_survey : false
  end
  
  def GetFullPublicationName
   # if we set the pseudonym in people table, use that
   if (self.pseudonym != nil)
        name = GetFullNameHelper(self.pseudonym.first_name,self.pseudonym.last_name,self.pseudonym.suffix)
        if (name =~ /^\s*$/)
           name = GetFullName()
        end
        return name
    else
        return GetFullName()
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
    return (GetSurveyQuestionResponse('g95q1'))    
  end
  
  def GetSurveyQuestionResponse(questionId)
    if (self.hasSurvey?)
         survey = SmerfFormsSurveyrespondent.find_user_smerf_form(self.survey_respondent.id, 1)
         if (survey == nil)
           return nil
         else
           if (survey.responses[questionId] != "")
           return survey.responses[questionId]
         else
           return nil
         end
       end
     else
       return nil
     end
  end
  
  def GetWebSite()
       return (GetSurveyQuestionResponse('g95q2'))    
  end
 
  def GetFacebookInfo()
    return (GetSurveyQuestionResponse('g96q1'))    
  end
 
 def GetTwitterInfo()
   return (GetSurveyQuestionResponse('g96q2'))
 end
 
 def GetOtherSocialMediaInfo()
      return (GetSurveyQuestionResponse('g96q3'))
 end
 
 def GetPhotoUrl()
   doNotPostPhoto = GetSurveyQuestionResponse('g95q4')
   if (doNotPostPhoto)
     return "Do Not Post Photo"
   else
     return (GetSurveyQuestionResponse('g95q3'))
   end
 end
 
 def GetSurveyStartDate()
 #  startDate = GetSurveyQuestionResponse('g6s1q2')
 #  startTime = GetSurveyQuestionResponsen('g6s1q3')
   availability = GetSurveyQuestionResponse('g6q1')
   if (availability == nil)
     return nil
   end
   startDateTime =  Time.zone.parse(SITE_CONFIG[:conference][:start_date]);

   if (availability == '1')
     # start time is noon (add seconds since midnight to start day)
     startDateTime = startDateTime + 12.hours
   elsif (availability == '2')
      startDate = GetSurveyQuestionResponse('g6s1q2')
      daycode = startDate[0].to_i
      startTime = GetSurveyQuestionResponse('g6s1q3')
      hourcode = startTime[0].to_i
      #day code has 1 as the start day of the convention
      startDateTime = startDateTime + (daycode-1).days
      # 0 means they did not specify - we assume midnight (hour 0)
      if (hourcode != 0)
         # hour code starts with 1 as 10:00 am
         startDateTime = startDateTime + (hourcode+9).hours    
      end
   end
   return startDateTime
 end
 
 def GetSurveyEndDate()
 #  startDate = GetSurveyQuestionResponse('g6s1q2')
 #  startTime = GetSurveyQuestionResponsen('g6s1q3')
   availability = GetSurveyQuestionResponse('g6q1')
   numDays = SITE_CONFIG[:conference][:number_of_days]
   endDateTime =  Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + (numDays-1).days;
   
   if (availability == nil)
     return nil
   end
   if (availability == '1')
     # end time is 4pm (add seconds since midnight to start day)
     endDateTime = endDateTime + 16.hours
   elsif (availability == '2')
      endDate = GetSurveyQuestionResponse('g6s1q4')
      daycode = endDate[0].to_i
      endTime = GetSurveyQuestionResponse('g6s1q5')
      hourcode = endTime[0].to_i
      #day code has 1 as the start day of the convention
      endDateTime = endDateTime - (numDays-daycode).days
      # 0 means they did not specify - we assume midnight (hour 0)
      if (hourcode != 0)
         # hour code starts with 1 as 10:00 am
         endDateTime = endDateTime + (hourcode+9).hours     
      end
   end
   return endDateTime
 end
 
 def GetShareEmail()
   shareEmail = true

   if (self.hasSurvey?)
    surveyList = GetSurveyQuestionResponse('g93q7')
    if (surveyList != nil)
      if (surveyList.has_key?('3'))
          shareEmail = false
      end
    end
   end
   return shareEmail
  
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
