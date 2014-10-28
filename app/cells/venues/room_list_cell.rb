class Venues::RoomListCell < Cell::Rails

  def display
    render
  end

  def javascript(args)
    @caption = args.has_key?(:caption) ? args[:caption] : "rooms"
    @selectNotifyMethod = args.has_key?(:selectNotifyMethod) ? args[:selectNotifyMethod] : "function() {}"
    @clearNotifyMethod = args.has_key?(:clearNotifyMethod) ? args[:clearNotifyMethod] : "function() {}"
    @loadNotifyMethod = args.has_key?(:loadNotifyMethod) ? args[:loadNotifyMethod] : "function() {}"
    @pager = args.has_key?(:pager) ? args[:pager] : '#rooms-pager'
    @root_url = baseUri + (args.has_key?(:root_url) ? args[:root_url] : "/")
    @baseUrl = args.has_key?(:baseUrl) ? args[:baseUrl] : "rooms"
    @getGridData = args.has_key?(:getGridData) ? args[:getGridData] : "/list.json"
    
    @view = args.has_key?(:view) ? args[:view] : false
    @search = args.has_key?(:search) ? args[:search] : false
    @del = args.has_key?(:del) ? args[:del] : false
    @edit = args.has_key?(:edit) ? args[:edit] : false
    @add = args.has_key?(:add) ? args[:add] : false
    @refresh = args.has_key?(:refresh) ? args[:refresh] : false
    
    @name = args.has_key?(:name) ? args[:name] : true
    @setup = args.has_key?(:setup) ? args[:setup] : true
    @capacity = args.has_key?(:capacity) ? args[:capacity] : true
    @purpose = args.has_key?(:purpose) ? args[:purpose] : true
    @comment = args.has_key?(:comment) ? args[:comment] : true
    
    @extraClause = args.has_key?(:extraClause) ? args[:extraClause] : false
    @multiselect = args.has_key?(:multiselect) ? args[:multiselect] : false
        
    @modelType = args.has_key?(:modelType) ? args[:modelType] : 'null'
    @showControls = args.has_key?(:showControls) ? args[:showControls] : false
    
    render
  end

end
