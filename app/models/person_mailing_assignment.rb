class PersonMailingAssignment < ActiveRecord::Base
  attr_accessible :lock_version
  
  belongs_to  :person
  belongs_to  :mailing
  
  has_many  :mail_histories

end
