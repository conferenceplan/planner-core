class EditedBio < ActiveRecord::Base
  belongs_to  :person 

  acts_as_audited :parent => :person

end
