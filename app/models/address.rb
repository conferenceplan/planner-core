class Address < ActiveRecord::Base
  attr_accessible :lock_version, :isvalid, :addressable_id, :addressable_type, :person_id
  
  belongs_to :person
  belongs_to :addressable, :polymorphic => :true
  
  audited :associated_with => :person

end
