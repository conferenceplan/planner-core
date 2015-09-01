class Items::ItemListCell < Cell::Rails

  def display
    render
  end
  
  def javascript(args)
    @caption = args.has_key?(:caption) ? args[:caption] : "Program Items"
    @selectNotifyMethod = args.has_key?(:selectNotifyMethod) ? args[:selectNotifyMethod] : "function() {}"
    @clearNotifyMethod = args.has_key?(:clearNotifyMethod) ? args[:clearNotifyMethod] : "function() {}"
    @loadNotifyMethod = args.has_key?(:loadNotifyMethod) ? args[:loadNotifyMethod] : "function() {}"
    @pager = args.has_key?(:pager) ? args[:pager] : '#pager'
    @root_url = baseUri + (args.has_key?(:root_url) ? args[:root_url] : "/")
    @baseUrl = args.has_key?(:baseUrl) ? args[:baseUrl] : "programme_items"
    @subGridUrl = args.has_key?(:subGridUrl) ? args[:subGridUrl] : "/get_children"
    @getGridData = args.has_key?(:getGridData) ? args[:getGridData] : "/getList.json"
    
    @format_name = args.has_key?(:format_name) ? args[:format_name] : true
    @duration = args.has_key?(:duration) ? args[:duration] : true
    @room = args.has_key?(:room) ? args[:room] : true
    @day = args.has_key?(:day) ? args[:day] : true
    @time = args.has_key?(:time) ? args[:time] : true
    @ref_number = args.has_key?(:ref_number) ? args[:ref_number] : true
    
    @view = args.has_key?(:view) ? args[:view] : false
    @search = args.has_key?(:search) ? args[:search] : false
    @del = args.has_key?(:del) ? args[:del] : true
    @edit = args.has_key?(:edit) ? args[:edit] : false
    @add = args.has_key?(:add) ? args[:add] : false
    @refresh = args.has_key?(:refresh) ? args[:refresh] : false
    
    @multiselect = args.has_key?(:multiselect) ? args[:multiselect] : false
    
    @ignoreScheduled = args.has_key?(:ignoreScheduled) ? args[:ignoreScheduled] : false
    
    @extraClause = args.has_key?(:extraClause) ? args[:extraClause] : false
    
    @modelType = args.has_key?(:modelType) ? args[:modelType] : 'null'
    @modelTemplate = args.has_key?(:modelTemplate) ? args[:modelTemplate] : ""
    @showControls = args.has_key?(:showControls) ? args[:showControls] : false
    
    @showNbrParticipants = args.has_key?(:showNbrParticipants) ? args[:showNbrParticipants] : false
    
    render
  end

end
