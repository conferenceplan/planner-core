class Dash::HistoryController < PlannerController
  
  def items
    # Get a list of the changes to program items
    @changes = AuditService.getItemChangeHistory
  end
  
end
