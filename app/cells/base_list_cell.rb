class BaseListCell < Cell::Rails

  def display(args = {})
    @place = args.has_key?(:place) ? args[:place] : "base-list"
    render
  end

  def javascript(args)
    @place = args.has_key?(:place) ? args[:place] : "base-list"
    @selectNotifyMethod = args.has_key?(:selectNotifyMethod) ? args[:selectNotifyMethod] : "function() {}"
    @root_url = baseUri + (args.has_key?(:root_url) ? args[:root_url] : "/")
    # @baseUrl = args.has_key?(:baseUrl) ? args[:baseUrl] : "planner_docs/documents"
    @getGridData = args.has_key?(:getGridData) ? args[:getGridData] : ""
    
    @delayed = args.has_key?(:delayed) ? args[:delayed] : false
    
    @pageSize = args.has_key?(:pageSize) ? args[:pageSize] : 50
    @pageList = args.has_key?(:pageList) ? args[:pageList] : '[10, 25, 50, 100, 200]'
    @search = args.has_key?(:search) ? args[:search] : 'false'
    @showRefresh = args.has_key?(:showRefresh) ? args[:showRefresh] : 'false'
    @cardView = args.has_key?(:cardView) ? args[:cardView] : false
    @extraClause = args.has_key?(:extraClause) ? args[:extraClause] : ''
    
    @toolbar = args.has_key?(:toolbar) ? args[:toolbar] : ''

    @modelType = args.has_key?(:modelType) ? args[:modelType] : 'null'
    @modelTemplate = args.has_key?(:modelTemplate) ? args[:modelTemplate] : ""
    
    @modal_create_title = args.has_key?(:modal_create_title) ? args[:modal_create_title] : ""
    @modal_edit_title = args.has_key?(:modal_edit_title) ? args[:modal_edit_title] : ""
    @confirm_content = args.has_key?(:confirm_content) ? args[:confirm_content] : ""
    @confirm_title = args.has_key?(:confirm_title) ? args[:confirm_title] : ""
    
    @showControls = args.has_key?(:showControls) ? args[:showControls] : 'true'

    @controlDiv = args.has_key?(:controlDiv) ? args[:controlDiv] : 'item-control-area'

    @show_linkedto = args.has_key?(:show_linkedto) ? args[:show_linkedto] : 'false'
    @extra_model_params = args.has_key?(:extra_model_params) ? args[:extra_model_params] : 'null'
    render
  end

end
