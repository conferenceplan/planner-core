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
  
end
