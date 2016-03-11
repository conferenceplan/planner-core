#
#
#
module MailService
  extend SurveyHtmlFormatter
  
  # TODO - add variable to the survey template to say what state the person's acceptance status should be after they complete the survey
  # QUESTION - should we do this for the invite status as well?
  
  # Possible args:
  # @responses = args[:responses].responses # survey_to_html(args[:survey],args[:respondentDetails])

  def self.preview(person, mailing, base_url) 
    # get the template from the database that matches the specified use
    template = mailing.mail_template
    
    assignments = (mailing.mail_template && mailing.mail_template.mail_use == MailUse[:Schedule]) ? ProgramItemsService.findProgramItemsForPerson(person) : nil
    respondentDetails = person.survey_respondent
    survey = (mailing.mail_template && mailing.mail_template.survey) ? mailing.mail_template.survey : nil

    # Then generate the email content from the template and arguments
    generateEmailContent(template, {
            :person             => person,
            :key                => 'KEY', # do not show the key in the preview
            :survey             => survey,
            :survey_url         => (base_url && survey) ? (base_url + '/form/' + survey.alias) : '',
            :respondentDetails  => respondentDetails,
            :assignments        => {assignments: assignments, include_email: mailing.include_email}
          })
  end
  
  #
  #
  #
  def self.sendGeneralEmail(email, mail_use, survey = nil, respondentDetails = nil)
    config = MailConfig.first # it will be the first mail config anyway
    raise "there is no mail configuration" if !config

    if (survey)
      template = MailTemplate.first(:conditions => ["mail_use_id = ? and survey_id = ?",mail_use.id, survey.id])
    else  
      template = MailTemplate.first(:conditions => ["mail_use_id = ?",mail_use.id])
    end
    raise "can not find a template for the email" if !template
    
    toInviteState = template.transiton_invite_status

    content = generateEmailContent(template, {
            :person             => nil,
            :survey             => survey,
            :respondentDetails  => respondentDetails
          })

    begin
      PlannerMailer.send_email({
          from:     config.from,
          reply_to: config.reply_to,
          to:       email,
          cc:       config.cc,
          subject:  template.subject,
          title:    template.title,
          return_path: config.from,
          skip_premailer: true
        }, content
      ).deliver
      transitionPersonInviteStateAfterEmail(person, toInviteState) if toInviteState
    rescue => msg
      # THROW ERROR - TODO
    end    
  end
  
  #
  #
  #
  def self.sendEmail(person, mail_use, survey = nil, respondentDetails = nil)
    config = MailConfig.first # it will be the first mail config anyway
    raise "there is no mail configuration" if !config

    if (survey)
      template = MailTemplate.first(:conditions => ["mail_use_id = ? and survey_id = ?",mail_use.id, survey.id])
    else  
      template = MailTemplate.first(:conditions => ["mail_use_id = ?",mail_use.id])
    end
    raise "can not find a template for the email" if !template
    
    toInviteState = template.transiton_invite_status

    to = person.getDefaultEmail.email
    cc = config.cc
    
    content = generateEmailContent(template, {
            :person             => person,
            :survey             => survey,
            :respondentDetails  => respondentDetails
          })

    begin
      PlannerMailer.send_email({
          from:     config.from,
          reply_to: config.reply_to,
          to:       to,
          cc:       cc,
          subject:  template.subject,
          title:    template.title,
          return_path: config.from,
          skip_premailer: true
        }, content
      ).deliver
      saveMailHistory(person, nil, content, EmailStatus[:Sent], template.subject)
      transitionPersonInviteStateAfterEmail(person, toInviteState) if toInviteState
    rescue => msg
      saveMailHistory(person, nil, msg, EmailStatus[:Failed], template.subject)
      # THROW ERROR - TODO
    end    
  end
  
  #
  #
  #
  def self.transitionPersonInviteStateAfterEmail(person, toState)
    person.invitestatus = toState
    person.save!
  end
  
  #
  #
  #
  def self.sendEmailForMailing(person, mailing, base_url)
    # Generate the email given the template and the args
    config = MailConfig.first # it will be the first mail config anyway
    raise "there is no mail configuration" if !config

    template = mailing.mail_template
    raise "can not find a template for the email" if !template
    
    toInviteState = template.transiton_invite_status
    
    if (mailing.testrun && config.test_email) || person.getDefaultEmail
      to = mailing.testrun ? config.test_email : person.getDefaultEmail.email
      cc = mailing.testrun ? nil : config.cc
      assignments = (mailing.mail_template && mailing.mail_template.mail_use == MailUse[:Schedule]) ? ProgramItemsService.findProgramItemsForPerson(person) : nil
      respondentDetails = person.survey_respondent
      key = respondentDetails ? respondentDetails.key : generateSurveyKey(person) # get the key (or generate it)
      survey = (mailing.mail_template && mailing.mail_template.survey) ? mailing.mail_template.survey : nil
      
      content = generateEmailContent(template, {
              :person             => person,
              :key                => key, 
              :survey             => survey,
              :survey_url         => (base_url && survey) ? (base_url + '/form/' + survey.alias) : '',
              :respondentDetails  => person.survey_respondent,
              :assignments        => {assignments: assignments, include_email: mailing.include_email}
            })
  
      begin
        subject = template.subject
        subject += ' - ' + person.getFullName() if person
        PlannerMailer.send_email({
            from:     config.from,
            reply_to: config.reply_to,
            to:       to,
            cc:       cc,
            subject:  subject,
            title:    template.title,
            skip_premailer: true
          }, content
        ).deliver
        saveMailHistory(person, mailing, content, EmailStatus[:Sent], subject)
        transitionPersonInviteStateAfterEmail(person, toInviteState) if (toInviteState && !mailing.testrun)
      rescue Net::SMTPSyntaxError
      rescue EOFError
        # this indicates that the email address is not valid
      rescue => msg
        # EOFError
        throw msg
        # THROW ERROR ??? - this would cause a retry of the whole list, which would be an issue for dups
        # do not do a retry unless we can resume from the failed message only
      end
    end
  end

  #
  #
  #
  def self.saveMailHistory(person, mailing, content, email_status, subject = nil)
    pma = PersonMailingAssignment.find :first, :conditions => {:person_id => person, :mailing_id => mailing}

    mailHistory = MailHistory.new :person_mailing_assignment  => pma,
                                  :email                      => person.getDefaultEmail,
                                  :person                     => person,
                                  :testrun                    => (mailing ? mailing.testrun : false),
                                  :date_sent                  => DateTime.now,
                                  :content                    => content,
                                  :mailing                    => mailing,
                                  :email_status               => email_status,
                                  :subject                    => subject
        
    mailHistory.save
  end
  
  # TODO ? Do we need a method to generate a URL to the survey?
  
  # Utility methods for the content generation
  #
  # def self.survey_to_html(survey, respondentDetails)
    # # TODO
    # return "SURVEY RESPONSE"
  # end

  #
  # Convert the assignments for a person to HTML for inclusion in the email
  #
  def self.assignments_to_html(assignments_hash)
    result = ''
    
    if assignments_hash && assignments_hash[:assignments]
      assignments = assignments_hash[:assignments]
      include_email = assignments_hash[:include_email]
      noShareEmails = SurveyService.findPeopleWithDoNotShareEmail
      
      assignments.each do | assignment |
        # only interested in items that have been assigned to a time slot
        if (assignment.programmeItem && (assignment.programmeItem.time_slot || (assignment.programmeItem.parent_id != nil && assignment.programmeItem.parent.time_slot)))
          # item
          result += "<div>\n"
          # title
          result += '<h2>' + assignment.programmeItem.title  + "</h2>\n" if assignment.programmeItem
          
          # TODO - If it is a sub item the show part of and the parent info
          
          result += assignment_to_html(assignment.programmeItem, noShareEmails, include_email)
        
          # 
          result += "</div></br>\n"
        end
      end
    end
    
    return result
  end
  
  def self.assignment_to_html(programmeItem, noShareEmails, include_email)
    # time
   if (programmeItem.parent_id == nil)
      result = '<p>' + programmeItem.time_slot.start.strftime('%A %H:%M') + " - " + programmeItem.time_slot.end.strftime('%H:%M') 
      result += ', ' + programmeItem.room.name + ' (' + programmeItem.room.venue.name + ')' if programmeItem.room
      result += "</p>\n"
      # description
      result += '<p>' + programmeItem.precis + "</p>\n" if programmeItem.precis
      # participants (name + email)
      names = []
      programmeItem.programme_item_assignments.each do |asg|
        if asg.person != nil
          if asg.role == PersonItemRole['Participant'] || asg.role == PersonItemRole['Moderator']
            name = ''
            name = asg.person.getFullPublicationName()
            name += " (M)" if asg.role == PersonItemRole['Moderator']
            # use default email ...
            if !noShareEmails.index(asg.person) && include_email
              email = asg.person.getDefaultEmail
              name += " (" + email.email + ")\n" if email
            end
            names << name
          end
        end
      end
      result += '<p>' + names.join(', ') + "</p>\n"
      
      if (programmeItem.participant_notes && (programmeItem.participant_notes.to_s.strip.length != 0))
        result += "<h4>Notes</h4>\n"
        result += '<p>' + programmeItem.participant_notes + "</p>\n"
      end
    else
      result = 'part of: <b><big>' + programmeItem.parent.title  + "</big></b>\n" #programmeItem.parent
      result += assignment_to_html(programmeItem.parent, noShareEmails, include_email)
    end
    result
  end

  #
  #
  #
  def self.generateSurveyKey(person)
    survey_respondent = nil
    newKeyValue = 0
    begin
      newKeyValue = ('%05d' % rand(1e5))
      survey_respondent = SurveyRespondent.find_by_key(newKeyValue)
    end until survey_respondent == nil

    if (!person.survey_respondent)
      person.create_survey_respondent( :key => newKeyValue,
                                       :submitted_survey => false)
      person.save!                                       
    else
      person.survey_respondent.key = newKeyValue
      person.survey_respondent.save!
    end
    
    return newKeyValue
  end

protected

  #
  # Given an email template and a set of argument generate the body for the email
  #
  def self.generateEmailContent(template, args)
    return ERB.new(template.content, 0, "%<>").result(binding) # pass in a context with the parameters i.e. ruby binding
  end
  
end


# Person status changes
# Potential Invite, Volunteered, Invite Pending, Invited
# Uknown, Probable, Accepted, Declined - invitation set after filling in Program Survey (need to indicate which survey)

# There are multiple types of emails

# 1. Invite a person to fill in a survey
# - need to create a survey respondent if there is not already one (for the key for authentication)
# - set the state of the person to invited? (this should be an option on the state)
# 2. Schedule confirmation
# 3. Completed survey - thank you email
# 4. Informational email

