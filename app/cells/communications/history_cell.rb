class Communications::HistoryCell < Cell::Rails

  def display(args)
    @place = args.has_key?(:place) ? args[:place] : "mail-history"
    @pager = args.has_key?(:pager) ? args[:pager] : 'pager'
    render
  end

  def javascript(args)
    @place = args.has_key?(:place) ? args[:place] : "mail-history"
    @caption = args.has_key?(:caption) ? args[:caption] : "Mail History"
    @selectNotifyMethod = args.has_key?(:selectNotifyMethod) ? args[:selectNotifyMethod] : "function() {}"
    @clearNotifyMethod = args.has_key?(:clearNotifyMethod) ? args[:clearNotifyMethod] : "function() {}"
    @loadNotifyMethod = args.has_key?(:loadNotifyMethod) ? args[:loadNotifyMethod] : "function() {}"
    @pager = args.has_key?(:pager) ? args[:pager] : 'pager'
    @root_url = args.has_key?(:root_url) ? args[:root_url] : "/"
    @baseUrl = args.has_key?(:baseUrl) ? args[:baseUrl] : "communications/mail_history"
    @getGridData = args.has_key?(:getGridData) ? args[:getGridData] : "/list.json"

    @mailing = args.has_key?(:mailing) ? args[:mailing] : true
    @content = args.has_key?(:content) ? args[:content] : true
    @email_status = args.has_key?(:email_status) ? args[:email_status] : true
    @date_sent = args.has_key?(:date_sent) ? args[:date_sent] : true
    @testrun = args.has_key?(:testrun) ? args[:testrun] : true

    @view = args.has_key?(:view) ? args[:view] : false
    @search = args.has_key?(:search) ? args[:search] : false
    @del = args.has_key?(:del) ? args[:del] : false
    @edit = args.has_key?(:edit) ? args[:edit] : false
    @add = args.has_key?(:add) ? args[:add] : false
    @refresh = args.has_key?(:refresh) ? args[:refresh] : false
    @controlDiv = args.has_key?(:controlDiv) ? args[:controlDiv] : 'mail-history-control'
    
    @extraClause = args.has_key?(:extraClause) ? args[:extraClause] : nil
    
    @multiselect = args.has_key?(:multiselect) ? args[:multiselect] : false
    
    @modelType = args.has_key?(:modelType) ? args[:modelType] : 'null'
    @showControls = args.has_key?(:showControls) ? args[:showControls] : false
    
    @delayed = args.has_key?(:delayed) ? args[:delayed] : false
    
    render
  end

end
