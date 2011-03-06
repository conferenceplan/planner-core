class Address < ActiveRecord::Base
  belongs_to :person
  belongs_to :addressable, :polymorphic => :true
  
  acts_as_audited :parent => :person

end
