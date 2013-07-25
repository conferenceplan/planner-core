#
#
#
class Publication < ActiveRecord::Base
  audited

  belongs_to  :published, :polymorphic => true
  belongs_to  :original, :polymorphic => true
  
  belongs_to :user
end
