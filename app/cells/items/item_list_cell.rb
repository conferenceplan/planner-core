class Items::ItemListCell < Cell::Rails

  def display
    render
  end
  
  def javascript(args)
    @caption = args.has_key?(:caption) ? args[:caption] : "Program Items"
    @selectNotifyMethod = args.has_key?(:selectNotifyMethod) ? args[:selectNotifyMethod] : "function() {}"
    @clearNotifyMethod = args.has_key?(:clearNotifyMethod) ? args[:clearNotifyMethod] : "function() {}"
    @pager = args.has_key?(:pager) ? args[:pager] : '#pager'
    @root_url = args.has_key?(:root_url) ? args[:root_url] : "/"
    @baseUrl = args.has_key?(:baseUrl) ? args[:baseUrl] : "programme_items"
    @getGridData = args.has_key?(:getGridData) ? args[:getGridData] : "/getList.json"
    
    @view = args.has_key?(:view) ? args[:view] : false
    @search = args.has_key?(:search) ? args[:search] : false
    @del = args.has_key?(:del) ? args[:del] : true
    @edit = args.has_key?(:edit) ? args[:edit] : false
    @add = args.has_key?(:add) ? args[:add] : false
    @refresh = args.has_key?(:refresh) ? args[:refresh] : false
    
    @extraClause = args.has_key?(:extraClause) ? args[:extraClause] : false
    
    render
  end

end
