class Communications::MailHistoryController < PlannerController
  
  def list
    rows = params[:rows] ? params[:rows] : 15
    @page = params[:page] ? params[:page].to_i : 1
    idx = params[:sidx]
    order = params[:sord]
    nameSearch = params[:namesearch]
    filters = params[:filters]

    @currentId = params[:current_selection]
    page_to = params[:page_to]
    
    @count = MailReportsService.countItems filters, nameSearch

    if page_to && !page_to.empty?
      gotoNum = MailReportsService.countItems filters, nameSearch, page_to
      if gotoNum
        @page = (gotoNum / rows.to_i).floor
        @page += 1 if gotoNum % rows.to_i > 0
      end
    end

    if rows.to_i > 0
      @nbr_pages = (@count / rows.to_i).floor
      @nbr_pages += 1 if @count % rows.to_i > 0
    else
      @nbr_pages = 1
    end
    
    @mailItems = MailReportsService.findItems rows, @page, idx, order, filters, nameSearch
  end

end
