class Venues::VenueListCell < Cell::Rails

  def display
    render
  end
  
  def javascript(args)
    @caption = args.has_key?(:caption) ? args[:caption] : "Venues"
    @selectNotifyMethod = args.has_key?(:selectNotifyMethod) ? args[:selectNotifyMethod] : "function() {}"
    @clearNotifyMethod = args.has_key?(:clearNotifyMethod) ? args[:clearNotifyMethod] : "function() {}"
    @loadNotifyMethod = args.has_key?(:loadNotifyMethod) ? args[:loadNotifyMethod] : "function() {}"
    @pager = args.has_key?(:pager) ? args[:pager] : '#venues-pager'
    @root_url = args.has_key?(:root_url) ? args[:root_url] : "/"
    @baseUrl = args.has_key?(:baseUrl) ? args[:baseUrl] : "venue"
    @getGridData = args.has_key?(:getGridData) ? args[:getGridData] : "/list.json"
    
    @view = args.has_key?(:view) ? args[:view] : false
    @search = args.has_key?(:search) ? args[:search] : false
    @del = args.has_key?(:del) ? args[:del] : false
    @edit = args.has_key?(:edit) ? args[:edit] : false
    @add = args.has_key?(:add) ? args[:add] : false
    @refresh = args.has_key?(:refresh) ? args[:refresh] : false
    
    @extraClause = args.has_key?(:extraClause) ? args[:extraClause] : false
    @multiselect = args.has_key?(:multiselect) ? args[:multiselect] : false
        
    render
  end

end
