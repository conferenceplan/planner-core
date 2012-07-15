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
  
  def getDefaultPostalAddress()
    possibleAddresses = postal_addresses
    theAddress = nil
    if possibleAddresses
      possibleAddresses.each do |addr| 
        if addr.isdefault
          theAddress = addr
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
