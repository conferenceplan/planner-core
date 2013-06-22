class MailHistory < ActiveRecord::Base
  
  belongs_to :person_mailing_assignment
  
  has_enumerated :email_status, :class_name => 'EmailStatus'

  
end
