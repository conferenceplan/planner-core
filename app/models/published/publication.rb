#
#
#
class Published::Publication < ActiveRecord::Base
  belongs_to  :published, :polymorphic => true
  belongs_to  :original, :polymorphic => true
end
