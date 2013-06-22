class SurveyMailer < ActionMailer::Base
  include SurveyHtmlFormatter

  #
  # Generic email mechanism, uses templates that have been defined in the database
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
  
  def mailingEmail(person, mailing, args)
    # get the mail parameters from the database
    config = MailConfig.first # it will be the first mail config anyway
    
    # we have the mailing so get the template
    template = mailing.mail_template
    
    content = generateEmail(template, args)
    
    if (mailing.testrun)
      sendto = config.test_email
      ccTo = nil
    else
      sendto = person.getDefaultEmail
      ccTo = config.cc
    end

    # then send the email
    headers "return-path" => config.from
    recipients sendto
    cc        ccTo
    from      config.from
    subject   template.subject # to get from the mail template
    sent_on   Time.now
    content_type "text/html"
    body      :title => template.title, :body => content
  end
  
  def preview(person, mailuse, args) 
    # get the mail parameters from the database
    config = MailConfig.first # it will be the first mail config anyway
    
    # get the template from the database that matches the specified use
    template = MailTemplate.first(:conditions => ["mail_use_id = ?",mailuse.id])
    
    # do parameter substitution for the body
    if args[:responses] != nil
      @responses = args[:responses].responses
    end
    
    return ERB.new(template.content, 0, "%<>").result(binding) # pass in a context with the parameters i.e. ruby binding
  end
  
  def assignments_to_html(assignments)
    result = ''
    
    assignments.each do | assignment |
      
      # item
      result += '<div>'
      # title
      result += '<h2>' + assignment.programmeItem.title  + '</h2>'
      # time
      if (assignment.programmeItem.time_slot)
        result += '<p>' + assignment.programmeItem.time_slot.start.strftime('%A %H:%M') + " - " + assignment.programmeItem.time_slot.end.strftime('%H:%M') + '</p>'
      end
      # description
      result += '<p>' + assignment.programmeItem.precis + '</p>'
      # participants (name + email)
      names = []
      assignment.programmeItem.programme_item_assignments.each do |asg|
        if asg.person != nil
          if asg.role == PersonItemRole['Participant'] || asg.role == PersonItemRole['Moderator']
            name = asg.person.GetFullPublicationName()
            name += " (M)" if asg.role == PersonItemRole['Moderator']                
            asg.person.email_addresses.each do |addr|
              if addr.isdefault #&& (!@NoShareEmailers.index(asg.person))
                name += "(" + addr.email + ")"
              end
            end
          end
        end
        names << name
      end
        
      result += '<p>' + names.join(', ') + '</p>'
      
      # equipment
      result += '</div></br>'
    end
    
    return result
  end

private 
  
  def generateEmail(template, args)
    # do parameter substitution for the body
    if args[:responses] != nil
      @responses = args[:responses].responses
    end
    
    return ERB.new(template.content, 0, "%<>").result(binding) # pass in a context with the parameters i.e. ruby binding
  end
  
end
