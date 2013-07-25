class Exclusion < ActiveRecord::Base
  belongs_to  :person
  belongs_to  :excludable, :polymorphic => true

  audited :associated_with => :person
end
