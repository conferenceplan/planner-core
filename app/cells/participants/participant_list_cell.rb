class Participants::ParticipantListCell < Cell::Rails

  def display
    render
  end
  
  def javascript(args)
    @caption = args.has_key?(:caption) ? args[:caption] : "Participants"
    @selectNotifyMethod = args.has_key?(:selectNotifyMethod) ? args[:selectNotifyMethod] : "function() {}"
    @clearNotifyMethod = args.has_key?(:clearNotifyMethod) ? args[:clearNotifyMethod] : "function() {}"
    @pager = args.has_key?(:pager) ? args[:pager] : '#pager'
    @root_url = args.has_key?(:root_url) ? args[:root_url] : "/"
    @baseUrl = args.has_key?(:baseUrl) ? args[:baseUrl] : "participants"
    @getGridData = args.has_key?(:getGridData) ? args[:getGridData] : "/getList.json"
    
    @invite_status = args.has_key?(:invite_status) ? args[:invite_status] : true
    @invite_category = args.has_key?(:invite_category) ? args[:invite_category] : true
    @acceptance_status = args.has_key?(:acceptance_status) ? args[:acceptance_status] : true
    @has_survey = args.has_key?(:has_survey) ? args[:has_survey] : true
    
    @view = args.has_key?(:view) ? args[:view] : false
    @search = args.has_key?(:search) ? args[:search] : false
    @del = args.has_key?(:del) ? args[:del] : true
    @edit = args.has_key?(:edit) ? args[:edit] : true
    @add = args.has_key?(:add) ? args[:add] : true
    @refresh = args.has_key?(:refresh) ? args[:refresh] : false
    
    @extraClause = args.has_key?(:extraClause) ? args[:extraClause] : false
    
    @onlySurveyRespondents = args.has_key?(:onlySurveyRespondents) ? args[:onlySurveyRespondents] : false
    
    render
  end

end
