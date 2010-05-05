class Address < ActiveRecord::Base
  
  belongs_to  :person
  belongs_to  :addressable, :polymorphic => :true
  
end
