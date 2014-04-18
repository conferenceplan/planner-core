#
# Used to regenerate the exclusions from the surveys for the participants
#
class ExclusionJob

  #
  #  
  #
  def perform

    ConstraintService.updateExcludedItems
    ConstraintService.updateExcludedTimes    
    ConstraintService.updateAvailability
    
  end

end
