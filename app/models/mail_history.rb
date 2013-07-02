class MailHistory < ActiveRecord::Base
  
  belongs_to :person_mailing_assignment
  belongs_to :person
  belongs_to :mailing
  
  has_enumerated :email_status, :class_name => 'EmailStatus'

  def as_json(options={})
    res = super(options)
    
    res[:status] = email_status.name
    
    return res
  end

end
