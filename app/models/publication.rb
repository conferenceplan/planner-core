#
#
#
class Publication < ActiveRecord::Base
  acts_as_audited

  belongs_to  :published, :polymorphic => true
  belongs_to  :original, :polymorphic => true
  
  belongs_to :user
end
