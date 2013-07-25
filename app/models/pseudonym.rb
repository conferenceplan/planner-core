class Pseudonym < ActiveRecord::Base
  belongs_to  :person 
  
  audited :associated_with => :person

end
