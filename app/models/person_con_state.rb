class PersonConState < ActiveRecord::Base
  attr_accessible :invitestatus_id, :acceptance_status_id, :person_id, :invitation_category_id
  
  belongs_to :person
  
  belongs_to  :invitation_category
  
  has_enumerated  :acceptance_status, :class_name => 'AcceptanceStatus'
  has_enumerated  :invitestatus, :class_name => 'InviteStatus'
end
