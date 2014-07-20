class Surveys::QueryListCell < Cell::Rails

  def display
    render
  end

  def javascript(args)
    @start_date = SiteConfig.first
    @selectNotifyMethod = args.has_key?(:selectNotifyMethod) ? args[:selectNotifyMethod] : "function() {}"
    @clearNotifyMethod = args.has_key?(:clearNotifyMethod) ? args[:clearNotifyMethod] : "function() {}"
    @formCallback = args.has_key?(:formCallback) ? args[:formCallback] : "function() {}"
    
    render
  end

  def templates
    render
  end

end
