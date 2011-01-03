class FixEmails < ActiveRecord::Migration
  def self.up
    respondents = SurveyRespondent.find(:all)
    
    respondents.each do  |r|
      if r.person
        possibleEmails = r.person.email_addresses
        theEmail = ''
        if possibleEmails
          possibleEmails.each do |email| 
            if email.isdefault
              theEmail = email
            else # if the email is empty we want to take the first one (unless there is a default)
              if theEmail.empty
                theEmail = email
              end
            end
          end
        end
        r.email = theEmail.email
        r.save
      end
    end
  end
  
  def self.down
  end
end
