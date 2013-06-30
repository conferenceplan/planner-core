class MailHistory < ActiveRecord::Base
  
  belongs_to :person_mailing_assignment
  belongs_to :person
  belongs_to :mailing
  
  has_enumerated :email_status, :class_name => 'EmailStatus'

  
end
