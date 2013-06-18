class MailHistory < ActiveRecord::Base
  
  belongs_to :person_mailing_assignment
  
end
