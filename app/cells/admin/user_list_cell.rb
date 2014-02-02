class Admin::UserListCell < Cell::Rails

  def display(args)
    @place = args.has_key?(:place) ? args[:place] : "user-grid"
    @pager = args.has_key?(:pager) ? args[:pager] : 'pager'
    render
  end

  def javascript(args)
    @place = args.has_key?(:place) ? args[:place] : "user-grid"
    @caption = args.has_key?(:caption) ? args[:caption] : "Users"
    @selectNotifyMethod = args.has_key?(:selectNotifyMethod) ? args[:selectNotifyMethod] : "function() {}"
    @clearNotifyMethod = args.has_key?(:clearNotifyMethod) ? args[:clearNotifyMethod] : "function() {}"
    @loadNotifyMethod = args.has_key?(:loadNotifyMethod) ? args[:loadNotifyMethod] : "function() {}"
    @pager = args.has_key?(:pager) ? args[:pager] : 'pager'
    @root_url = args.has_key?(:root_url) ? args[:root_url] : "/"
    @baseUrl = args.has_key?(:baseUrl) ? args[:baseUrl] : "users/admin"
    @getGridData = args.has_key?(:getGridData) ? args[:getGridData] : "/list.json"
    
    @login = args.has_key?(:login) ? args[:login] : true
    @roles = args.has_key?(:roles) ? args[:roles] : true
    @login_count = args.has_key?(:login_count) ? args[:login_count] : true
    @failed_login_count = args.has_key?(:failed_login_count) ? args[:failed_login_count] : true
    
    @view = args.has_key?(:view) ? args[:view] : false
    @search = args.has_key?(:search) ? args[:search] : false
    @del = args.has_key?(:del) ? args[:del] : true
    @edit = args.has_key?(:edit) ? args[:edit] : true
    @add = args.has_key?(:add) ? args[:add] : true
    @refresh = args.has_key?(:refresh) ? args[:refresh] : false
  
    @extraClause = args.has_key?(:extraClause) ? args[:extraClause] : nil
    
    @multiselect = args.has_key?(:multiselect) ? args[:multiselect] : false
    
    @modelType = args.has_key?(:modelType) ? args[:modelType] : 'null'
    @showControls = args.has_key?(:showControls) ? args[:showControls] : false
    
    render
  end

end
