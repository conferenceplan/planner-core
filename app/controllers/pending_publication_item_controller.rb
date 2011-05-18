class PendingPublicationItemController < PlannerController
  
  # list the pending programme items
  def list
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]
    nameSearch = params[:namesearch]
    
    clause = createWhereClause(params[:filters]) 

    if nameSearch && ! nameSearch.empty?
      clause = addClause(clause,'programme_items.title like ?','%' + nameSearch + '%')
    end

    args = { :conditions => clause }

    args.merge!( :joins => 'LEFT JOIN programme_items on programme_items.id = programme_item_id' )

    
    # First we need to know how many records there are in the database
    rows = "10" if rows == nil
    @page = "1" if @page == nil
    @count = PendingPublicationItem.count args
    @nbr_pages = (@count / rows.to_i).floor
    @nbr_pages += 1 if @count % rows.to_i > 0
    
    # Then we get the actual data we want from the DB
    offset = (@page.to_i - 1) * rows.to_i
    args.merge!(:offset => offset, :limit => rows) #, :order => idx + " " + order)
    
    @pendingItems = PendingPublicationItem.find :all, args
    
    # We return the list of ProgrammeItems as an XML structure which the 'table' can use.
    respond_to do |format|
      format.html { render :layout => 'plain' } # list.html.erb
    end
  end
  
  # Adds the programme item(s) to the pending list
  # also maintain relationship back to the programme item
  def add
    items = params[:items]
    if items
      items.each do |item|
        programmeItem = ProgrammeItem.find(item)
        pendingItem = PendingPublicationItem.new
        pendingItem.programme_item = programmeItem
        pendingItem.save
      end
    end
  end
  
end
