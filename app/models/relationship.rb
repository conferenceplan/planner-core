class Relationship < ActiveRecord::Base
  belongs_to  :person
  belongs_to  :relatable, :polymorphic => true
  
  acts_as_audited :parent => :person

end
