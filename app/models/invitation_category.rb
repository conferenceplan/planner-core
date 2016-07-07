class InvitationCategory < ActiveRecord::Base
  attr_accessible :lock_version, :name, :position
  
  before_destroy :check_for_use

private

  def check_for_use
    if PersonConState.where( :invitation_category_id => id ).exists?
      raise "can not delete an invitation category that is being used"
    end
  end
 
end
