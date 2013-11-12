class Surveys::QueryListCell < Cell::Rails

  def display
    render
  end

  def javascript(args)
    # @place = args.has_key?(:place) ? args[:place] : "#query-list-region-view"
    @selectNotifyMethod = args.has_key?(:selectNotifyMethod) ? args[:selectNotifyMethod] : "function() {}"
    # @drillDownNotifyMethod = args.has_key?(:drillDownNotifyMethod) ? args[:drillDownNotifyMethod] : "function() {}"
    
    render
  end

  def templates
    render
  end

end
