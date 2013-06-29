class PersonMailingAssignment < ActiveRecord::Base
  belongs_to  :person
  belongs_to  :mailing
  
  has_many  :mail_histories

end
