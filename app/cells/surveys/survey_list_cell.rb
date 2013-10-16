class Surveys::SurveyListCell < Cell::Rails

  def display
    render
  end

  def javascript(args)
    @selectNotifyMethod = args.has_key?(:selectNotifyMethod) ? args[:selectNotifyMethod] : "function() {}"
    @drillDownNotifyMethod = args.has_key?(:drillDownNotifyMethod) ? args[:drillDownNotifyMethod] : "function() {}"
    
    render
  end
  
  def templates
    render
  end

end
