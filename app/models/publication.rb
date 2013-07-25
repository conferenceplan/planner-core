#
#
#
class Publication < ActiveRecord::Base
  audited :allow_mass_assignment => true

  belongs_to  :published, :polymorphic => true
  belongs_to  :original, :polymorphic => true
  
  belongs_to :user
end
