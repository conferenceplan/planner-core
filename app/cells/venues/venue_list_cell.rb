class Venues::VenueListCell < Cell::Rails

  def display
    render
  end
  
  def templates
    render
  end
  
  def javascript(args)
    @selectNotifyMethod = args.has_key?(:selectNotifyMethod) ? args[:selectNotifyMethod] : "function() {}"
        
    render
  end

end
