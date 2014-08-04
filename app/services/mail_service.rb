#
#
#
module MailService
  extend SurveyHtmlFormatter
  
  # TODO - add variable to the survey template to say what state the person's acceptance status should be after they complete the survey
  # QUESTION - should we do this for the invite status as well?
  
  # Possible args:
  # @responses = args[:responses].responses # survey_to_html(args[:survey],args[:respondentDetails])

  def self.preview(person, mailing) 
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
            :respondentDetails  => respondentDetails,
            :assignments        => assignments
          })
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
          title:    template.title
        }, content
      ).deliver
      saveMailHistory(person, nil, content, EmailStatus[:Sent])
      transitionPersonInviteStateAfterEmail(person, toInviteState) if toInviteState
    rescue => msg
      saveMailHistory(person, nil, msg, EmailStatus[:Failed])
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
  def self.sendEmailForMailing(person, mailing)
    # Generate the email given the template and the args
    config = MailConfig.first # it will be the first mail config anyway
    raise "there is no mail configuration" if !config

    template = mailing.mail_template
    raise "can not find a template for the email" if !template
    
    toInviteState = template.transiton_invite_status
    
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
            :respondentDetails  => person.survey_respondent,
            :assignments        => assignments
          })

    begin
      PlannerMailer.send_email({
          from:     config.from,
          reply_to: config.reply_to,
          to:       to,
          cc:       cc,
          subject:  template.subject,
          title:    template.title
        }, content
      ).deliver
      saveMailHistory(person, mailing, content, EmailStatus[:Sent])
      transitionPersonInviteStateAfterEmail(person, toInviteState) if toInviteState && !mailing.testrun
    rescue => msg
      saveMailHistory(person, mailing, msg, EmailStatus[:Failed])
      # THROW ERROR - TODO
    end

  end

  #
  #
  #
  def self.saveMailHistory(person, mailing, content, email_status)
    pma = PersonMailingAssignment.find :first, :conditions => {:person_id => person, :mailing_id => mailing}

    mailHistory = MailHistory.new :person_mailing_assignment  => pma,
                                  :email                      => person.getDefaultEmail,
                                  :person                     => person,
                                  :testrun                    => (mailing ? mailing.testrun : false),
                                  :date_sent                  => DateTime.now,
                                  :content                    => content,
                                  :mailing                    => mailing,
                                  :email_status               => email_status
        
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
  def self.assignments_to_html(assignments)
    result = ''
    
    if assignments
      noShareEmails = SurveyService.findPeopleWithDoNotShareEmail
      
      assignments.each do | assignment |
        if (assignment.programmeItem && assignment.programmeItem.time_slot) # only interested in items that have been assigned to a time slot
          # item
          result += "<div>\n"
          # title
          result += '<h2>' + assignment.programmeItem.title  + "</h2>\n" if assignment.programmeItem
          # time
          result += '<p>' + assignment.programmeItem.time_slot.start.strftime('%A %H:%M') + " - " + assignment.programmeItem.time_slot.end.strftime('%H:%M') 
          result += ', ' + assignment.programmeItem.room.name + ' (' + assignment.programmeItem.room.venue.name + ')' if assignment.programmeItem.room
          result += "</p>\n"
          # description
          result += '<p>' + assignment.programmeItem.precis + "</p>\n" if assignment.programmeItem.precis
          # participants (name + email)
          names = []
          assignment.programmeItem.programme_item_assignments.each do |asg|
            if asg.person != nil
              if asg.role == PersonItemRole['Participant'] || asg.role == PersonItemRole['Moderator']
                name = ''
                name = asg.person.getFullPublicationName()
                name += " (M)" if asg.role == PersonItemRole['Moderator']                
                asg.person.email_addresses.each do |addr|
                  if addr.isdefault && (!noShareEmails.index(asg.person))
                    name += "(" + addr.email + ")\n"
                  end
                end
                names << name
              end
            end
          end
          result += '<p>' + names.join(', ') + "</p>\n"
          
          if (assignment.programmeItem.participant_notes && (assignment.programmeItem.participant_notes.to_s.strip.length != 0))
            result += "<h4>Notes for Participant(s)</h4>\n"
            result += '<p>' + assignment.programmeItem.participant_notes + "</p>\n"
          end
        
          # 
          result += "</div></br>\n"
        end
      end
    end
    
    return result
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

