class Exclusion < ActiveRecord::Base
  belongs_to  :person
  belongs_to  :excludable, :polymorphic => true

  acts_as_audited :parent => :person
end
