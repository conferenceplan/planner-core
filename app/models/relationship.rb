class Relationship < ActiveRecord::Base
  attr_accessible :lock_version, :relationship_type, :person_id, :relatable_id, :relatable_type
  
  belongs_to  :person
  belongs_to  :relatable, :polymorphic => true
  
  audited :parent => :person

end
