class ItemSummaryCell < Cell::Rails

  # Get a summary of the number of items etc.
  def display
    
    # Number program items
    @nbrOfItems = ProgramItemsService.getNumberOfItems
    # Number of scheduled items
    @nbrOfScheduledItems = ProgramItemsService.getNumberOfScheduledItems
    # Number of conflicts
    @nbrOfConflicts = ProgramItemsService.getNumberOfConflicts
    
    render
  end

end
