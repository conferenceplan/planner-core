#
#
#
class Publication < ActiveRecord::Base
  attr_accessible :lock_version, :published_id, :published_type, :original_id, :original_type, :user_id, :publication_date, :published, :original
  
  audited :allow_mass_assignment => true

  belongs_to  :published, :polymorphic => true
  belongs_to  :original, :polymorphic => true
  
  belongs_to :user
end
