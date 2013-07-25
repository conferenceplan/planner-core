class Relationship < ActiveRecord::Base
  belongs_to  :person
  belongs_to  :relatable, :polymorphic => true
  
  audited :parent => :person

end
