class NavSummaryCell < Cell::Rails

  def display(args)
    @width = args[:width]
    @target = args[:target]
    @title = args[:title]
    @colour = args[:colour]
    @src = args[:src]
    @icon = args[:icon] ? args[:icon] : 'expand'
    
    render
  end

end
