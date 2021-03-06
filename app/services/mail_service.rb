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
    
    assignments = mailing.mail_template ? ProgramItemsService.findProgramItemsForPerson(person) : nil
    respondentDetails = person.survey_respondent
    survey = (mailing.mail_template && mailing.mail_template.survey) ? mailing.mail_template.survey : nil

    # Then generate the email content from the template and arguments
    generateEmailContent(template, {
            :person             => person,
            :key                => 'KEY', # do not show the key in the preview
            :survey             => survey,
            :survey_url         => (base_url && survey) ? (base_url + '/form/' + survey.alias) : '',
            :respondentDetails  => respondentDetails,
            :assignments        => assignments
          })
  end
  
  #
  #
  #
  def self.sendGeneralEmail(email, mail_use, survey = nil, respondentDetails = nil)
    config = MailConfig.first # it will be the first mail config anyway
    raise "there is no mail configuration" if !config

    if (survey)
      template = MailTemplate.where(["mail_use_id = ? and survey_id = ?",mail_use.id, survey.id]).first
    else  
      template = MailTemplate.where(["mail_use_id = ?",mail_use.id]).first
    end
    raise "can not find a template for the email" if !template
    
    toInviteState = template.transiton_invite_status

    content = generateEmailContent(template, {
            :person             => nil,
            :survey             => survey,
            :respondentDetails  => respondentDetails
          })

    begin
      PlannerMailer.send_email({ #
          from:     config.from,
          reply_to: config.reply_to,
          to:       email,
          subject:  template.subject,
          title:    template.title,
          return_path: config.from,
          skip_premailer: true,
          content_type: "text/html",
          body: content
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
      template = MailTemplate.where(["mail_use_id = ? and survey_id = ?",mail_use.id, survey.id]).first
    else  
      template = MailTemplate.where(["mail_use_id = ?",mail_use.id]).first
    end
    raise "can not find a template for the email" if !template
    
    toInviteState = template.transiton_invite_status

    to = person.getDefaultEmail.email
    if to && !to.blank?
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
            subject:  template.subject,
            title:    template.title,
            return_path: config.from,
            skip_premailer: true,
            content_type: "text/html",
            body: content
          }, content
        ).deliver
        saveMailHistory(person, nil, content, EmailStatus[:Sent], template.subject)
        transitionPersonInviteStateAfterEmail(person, toInviteState) if toInviteState
      rescue => msg
        saveMailHistory(person, nil, msg, EmailStatus[:Failed], template.subject)
        # THROW ERROR - TODO
      end    
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
  def self.sendEmailForMailing(person, mailing, base_url, test_address: nil, send_test: false)
    # Generate the email given the template and the args
    config = MailConfig.first # it will be the first mail config anyway
    raise "there is no mail configuration" if !config

    template = mailing.mail_template
    raise "can not find a template for the email" if !template
    
    toInviteState = template.transiton_invite_status

    _test_address = test_address || config.test_email
    
    if (send_test && _test_address.present?) || (person.getDefaultEmail && person.getDefaultEmail.email.present?)
      to = send_test ? _test_address : person.getDefaultEmail.email
      
      if to.present?
        cc = ""
        
        if !send_test && mailing.cc_all
          # add all the email addresses for the person to the CC
          person.email_addresses.each do |addr|
            if addr.email != to
              cc += ", " if !cc.blank?
              cc += addr.email
            end
          end
        end
        assignments = mailing.mail_template ? ProgramItemsService.findProgramItemsForPerson(person) : nil
        respondentDetails = person.survey_respondent
        key = (respondentDetails && !respondentDetails.key.blank?) ? respondentDetails.key : generateSurveyKey(person) # get the key (or generate it)
        survey = (mailing.mail_template && mailing.mail_template.survey) ? mailing.mail_template.survey : nil
        
        content = generateEmailContent(template, {
                :person             => person,
                :key                => key, 
                :survey             => survey,
                :survey_url         => (base_url && survey) ? (base_url + '/form/' + survey.alias) : '',
                :respondentDetails  => person.survey_respondent,
                :assignments        => assignments
              }, {
                title: template.subject.blank? ? template.title : template.subject,
                batch: mailing.mailing_number.to_s 
                # add in organization and conference?
                })
    
        begin
          subject = template.subject
          PlannerMailer.send_email({
              from:     config.from,
              reply_to: config.reply_to,
              to:       to,
              cc:       cc,
              subject:  subject,
              title:    template.title,
              skip_premailer: true,
              content_type: "text/html",
              body: content
            }, content
          ).deliver_now
          saveMailHistory(person, mailing, content, EmailStatus[:Sent], subject) if !send_test
          transitionPersonInviteStateAfterEmail(person, toInviteState) if (toInviteState && !send_test)
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
  end

  #
  #
  #
  def self.saveMailHistory(person, mailing, content, email_status, subject = nil)
    pma = PersonMailingAssignment.where({:person_id => person, :mailing_id => mailing}).first
    _email = person.getDefaultEmail.email if person.getDefaultEmail
    
    mailHistory = MailHistory.new :person_mailing_assignment  => pma,
                                  :email                      => _email,
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
  def self.assignments_detailed_to_html(assignments)
    assignments_to_html(assignments, include_email: true, full_details: true)
  end

  def self.assignments_with_emails_to_html(assignments)
    assignments_to_html(assignments, include_email: true)
  end

  def self.assignments_to_html(assignments, include_email: false, full_details: false)
    result = ''
    noShareEmails = SurveyService.findPeopleWithDoNotShareEmail
    
    assignments.each do | assignment |
      # only interested in items that have been assigned to a time slot
      if (assignment.programmeItem && (assignment.programmeItem.time_slot || (assignment.programmeItem.parent_id != nil && assignment.programmeItem.parent.time_slot)))
        # item
        result += "<div>\n"
        # title
        result += '<h2>' + assignment.programmeItem.title  + "</h2>\n" if assignment.programmeItem
        
        # TODO - type of meeting
        result += ("Format: " + assignment.programmeItem.format.name + '<br>') if assignment.programmeItem.format
        # TODO - If it is a sub item the show part of and the parent info
        
        result += assignment_to_html(assignment.programmeItem, noShareEmails, include_email, full_details)
      
        # 
        result += "</div></br>\n"
      end
    end
    
    result
  end
  
  def self.assignment_to_html(programmeItem, noShareEmails, include_email, full_details)
    # time
   if (programmeItem.parent_id == nil)
     # TODO - localise date and time formating
      result = '<p>' + programmeItem.time_slot.start.strftime('%e %b %Y, %A %H:%M') + " - " + programmeItem.time_slot.end.strftime('%H:%M') 
      result += ', ' + programmeItem.room.name + ' (' + programmeItem.room.venue.name + ')' if programmeItem.room
      result += "</p>\n"
      # description
      result += '<p>' + programmeItem.description + "</p>\n" if programmeItem.description
      # participants (name + email)
      names = []
      # TODO - ensure order
      programmeItem.programme_item_assignments.sort{|a,b| a.sort_order <=> b.sort_order}.each do |asg|
        if asg.person != nil
          if asg.role == PersonItemRole['Participant'] || asg.role == PersonItemRole['OtherParticipant'] || asg.role == PersonItemRole['Moderator']
            
            name = full_details ? "<p><b>" : ""
            name += asg.person.getFullPublicationName()
            name += " (" + asg.person.company + ")" if asg.person.company.present?
            name += " (M)" if asg.role == PersonItemRole['Moderator']
            name += "</b>" if full_details
            # use default email ...
            if !noShareEmails.index(asg.person) && include_email
              name += "<br>" if full_details
              email = asg.person.getDefaultEmail
              name += " (" + email.email + ")" if email && email.email.present?
            end
            if full_details
              if asg.person.getDefaultPhoneNumber && asg.person.default_phone_number.present?
                name += "<br>"
                name += (asg.person.getDefaultPhoneNumber.phone_type.name.first.downcase +  ": ")
                name += asg.person.default_phone_number
              end
              if asg.person.edited_bio
                name += "<br>" + asg.person.edited_bio.linkedin_url if asg.person.edited_bio.linkedin_url.present?
                name += "<br>" + asg.person.edited_bio.twitter_url if asg.person.edited_bio.twitter_url.present?
                name += "<br>" + asg.person.edited_bio.facebook_url if asg.person.edited_bio.facebook_url.present?
                name += "<br>" + asg.person.edited_bio.website_url if asg.person.edited_bio.website_url.present?
              end
            end
            name += "</p>" if full_details

            names << name
          end
        end
      end
      result += '<p>' + names.join(', ') + "</p>\n" if !full_details
      result += names.join('') if full_details
      
      if (programmeItem.participant_notes && (programmeItem.participant_notes.to_s.strip.length != 0))
        result += "<h4>Notes</h4>\n"
        result += '<p>' + programmeItem.participant_notes + "</p>\n"
      end
    else
      result = 'part of: <b><big>' + programmeItem.parent.title  + "</big></b>\n" #programmeItem.parent
      result += assignment_to_html(programmeItem.parent, noShareEmails, include_email, full_details)
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
      survey_respondent = SurveyRespondent.find_by(key: newKeyValue)
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
  def self.generateEmailContent(template, args, tracker_opts = nil)
    return ERB.new(
      add_trackers(template.content, tracker_opts),
      0, "%<>"
    ).result(binding) # pass in a context with the parameters i.e. ruby binding
  end
  
  def self.tracker_template
    %w(
      <p>
        <img 
        src="https://www.google-analytics.com/collect?
        v=1&
        tid=%<ua_code>s&
        cid=%<batch_id>s&
        t=event&
        ec=email&
        ea=open&
        el=openemail&
        cs=grenadine-mail&
        cm=email&
        cn=%<campaign_title>s&
        cm1=1"
        />
      </p>
    ).join('')
  end
  
  def self.add_trackers(content, tracker_opts = nil)
    gr_tracker = ENV['GR_GOOGLE_ANALYTICS']
    content if !tracker_opts && gr_tracker

    batch_id = tracker_opts[:batch]
    campaign_title = tracker_opts[:title]

    tracker = format(
      tracker_template,
      batch_id: batch_id,
      campaign_title: campaign_title,
      ua_code: gr_tracker
    )
    
    content + tracker
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

