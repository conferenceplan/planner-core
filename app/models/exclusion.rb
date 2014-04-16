class Exclusion < ActiveRecord::Base
  attr_accessible :lock_version, :source, :excludable_id, :excludable_type, :person_id
  belongs_to  :person
  belongs_to  :excludable, :polymorphic => true

  audited :associated_with => :person
end
