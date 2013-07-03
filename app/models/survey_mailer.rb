class SurveyMailer < ActionMailer::Base
  include SurveyHtmlFormatter

  #
  # Generic email mechanism, uses templates that have been defined in the database
  # TODO - deprecate this and use the new mechanism, need to add the other variables to the arguments
  #  
  def email(recipient, mailuse, args)
    # get the mail parameters from the database
    config = MailConfig.first # it will be the first mail config anyway
    
    # get the template from the database that matches the specified use
    template = MailTemplate.first(:conditions => ["mail_use_id = ?",mailuse.id])
    
    
    # do parameter substitution for the body
    if args[:responses] != nil
      @responses = args[:responses].responses
    end
    content = ERB.new(template.content, 0, "%<>").result(binding) # pass in a context with the parameters i.e. ruby binding
    
    # then send the email
    headers "return-path" => config.from
    recipients recipient
    cc        config.cc
    from      config.from
    subject   template.subject # to get from the mail template
    sent_on   Time.now
    content_type "text/html"
    body      :title => template.title, :body => content
  end
  
  #
  # Generic email mechanism used for the mailings
  #
  def mailingEmail(person, mailing, mailHistory, args)
    begin
      # get the mail parameters from the database
      config = MailConfig.first # it will be the first mail config anyway
      raise "there is no mail configuration" if !config
      
      # we have the mailing so get the template
      template = mailing.mail_template
      raise "can not fine a template for the email" if !template
     
      content = SurveyMailer.generateEmail(template, args)
      mailHistory.content = content
    
      if (mailing.testrun)
        sendto = config.test_email
        ccTo = nil
      else
        sendto = person.getDefaultEmail.email
        ccTo = config.cc
      end
      
      raise "No email found for the recipient" if !sendto

      # then send the email
      headers "return-path" => config.from
      recipients sendto
      cc        ccTo
      from      config.from
      subject   template.subject # to get from the mail template
      sent_on   Time.now
      content_type "text/html"
      body      :title => template.title, :body => content
    rescue Exception => e
      logger.error e.message
      # self.message.perform_deliveries = false
      
      # Log the problem
      raise e
    end
  end

  #
  #
  #  
  def self.preview(person, mailing, args) 
    # get the template from the database that matches the specified use
    template = mailing.mail_template
    
    # Then generate the email content from the template and arguments
    SurveyMailer.generateEmail(template, args)
  end
  
  #
  #
  #
  def self.assignments_to_html(assignments)
    result = ''
    
    noShareEmails = SurveyService.findPeopleWithDoNotShareEmail
    
    assignments.each do | assignment |
      if (assignment.programmeItem && assignment.programmeItem.time_slot) # only interested in items that have been assigned to a time slot
        # item
        result += "<div>\n"
        # title
        result += '<h2>' + assignment.programmeItem.title  + "</h2>\n" if assignment.programmeItem
        # time
        result += '<p>' + assignment.programmeItem.time_slot.start.strftime('%A %H:%M') + " - " + assignment.programmeItem.time_slot.end.strftime('%H:%M') + "</p>\n"
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
      
        # 
        result += "</div></br>\n"
      end
    end
    
    return result
  end

private 
  
  def self.generateEmail(template, args)
    return ERB.new(template.content, 0, "%<>").result(binding) # pass in a context with the parameters i.e. ruby binding
  end
  
end
