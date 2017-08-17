class PersonMailingAssignment < ActiveRecord::Base
  attr_accessible :lock_version, :person_id, :mailing_id
  
  belongs_to  :person, touch: true
  belongs_to  :mailing, touch: true
  
  has_many  :mail_histories

end
