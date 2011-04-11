class ProgrammeItemsController < PlannerController
  
  def index
    @programmeItems = ProgrammeItem.find :all
  end
  def show
    @programmeItem = ProgrammeItem.find(params[:id])
    @editable = params[:edit] ? params[:edit] == "true" : true
    
    @participantAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id = ?', @programmeItem, PersonItemRole['Participant']] 
    @reserveAssociations = ProgrammeItemAssignment.find :all, :conditions => ['programme_item_id = ? AND role_id = ?', @programmeItem, PersonItemRole['Reserved']] 
    
    render :layout => 'content'
  end
  def create
# NOTE - name of the programmeItem passed in from form
    @programmeItem = ProgrammeItem.new(params[:programme_item])
    if (@programmeItem.save)
       redirect_to :action => 'index', :id => @programmeItem
    else
      render :action => 'new'
    end 
  end
  def new
    @programmeItem = ProgrammeItem.new
    @programmeItem.duration = 60
    @programmeItem.minimum_people = 3
    @programmeItem.maximum_people = 5
    @programmeItem.print = true
  end
  
  def edit
    @programmeItem = ProgrammeItem.find(params[:id])
    render :layout => 'content'
  end
  
  def update
    @programmeItem = ProgrammeItem.find(params[:id])
    if @programmeItem.update_attributes(params[:programme_item])
      redirect_to :action => 'show', :id => @programmeItem
    else
      render :action => 'edit', :layout => 'content'
    end
  end
  
  def destroy
    @programmeItem = ProgrammeItem.find(params[:id])
    @programmeItem.destroy
    redirect_to :action => 'index'
  end
  #
  
  def list
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]
    context = params[:context]
    nameSearch = params[:namesearch]
    ignoreScheduled = params[:igs]

    clause = createWhereClause(params[:filters], 
                  ['format_id'],
                  ['format_id'])

    # add the name search of the title
    if nameSearch && ! nameSearch.empty?
      clause = addClause(clause,'title like ?','%' + nameSearch + '%')
    end
    if ignoreScheduled
      clause = addClause( clause, 'room_item_assignments.programme_item_id is null', nil )
    end

    args = { :conditions => clause }
    
    if ignoreScheduled
      args.merge!( :joins => 'LEFT JOIN room_item_assignments ON room_item_assignments.programme_item_id = programme_items.id' )
    end

    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB
    args.merge!(:include => :format)
    
    tagquery = ""
    if context
      if context.class == HashWithIndifferentAccess
        context.each do |key, ctx|
          tagquery += ".tagged_with('" + params[:tags][key] + "', :on => '" + ctx + "', :any => true)"
        end
      else
        tagquery += ".tagged_with('" + params[:tags] + "', :on => '" + context + "', :op => true)"
      end
    end
    
    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB
    if tagquery.empty?
      @count = ProgrammeItem.count args
    else
      @count = eval "ProgrammeItem#{tagquery}.count :all, " + args.inspect
    end

    @nbr_pages = (@count / rows.to_i).floor
    @nbr_pages += 1 if @count % rows.to_i > 0
    
    offset = (@page.to_i - 1) * rows.to_i
    args.merge!(:offset => offset, :limit => rows, :order => idx + " " + order)
    if tagquery.empty?
      @programmeItems = ProgrammeItem.find :all, args
    else
      @programmeItems = eval "ProgrammeItem#{tagquery}.find :all, " + args.inspect
    end
    
    # We return the list of ProgrammeItems as an XML structure which the 'table' can use.
    respond_to do |format|
      format.html { render :layout => 'plain' } # list.html.erb
      format.xml
    end
  end
  
  #
  # Update the participants associated with this programme item
  #  
  def updateParticipants
    @programmeItem = ProgrammeItem.find(params[:id])

    # 1. Clear out the current set of participants    
    @programmeItem.people.clear # remove it from the person. NOTE: this does not update the audit table... TODO
    @programmeItem.save
    
    # 2. Create the new set
    candidates = params['item-participants'] # this is a collection of the information about the participants to add (id and role)
    if candidates
      candidates.each do |candidate_id, candidate|
        p = Person.find(candidate[:person_id])
        # NOTE : had to put the programme item id in there explicitly because AR seemed not to work it out when using :programmeItem...
        # Using this mechanism so we can specify the role(s)
        assignment = ProgrammeItemAssignment.create(:programme_item_id => @programmeItem.id, :person => p, :role => PersonItemRole['Participant'])
        assignment.save
      end
    end
    
    reserve = params['item-reserve-participants'] # this is a collection of the information about the participants to add (id and role)
    if reserve
      reserve.each do |candidate_id, candidate|
        p = Person.find(candidate[:person_id])
        assignment = ProgrammeItemAssignment.create(:programme_item_id => @programmeItem.id, :person => p, :role => PersonItemRole['Reserved'])
        assignment.save
      end
    end
  
    respond_to do |format|
      format.html { render :layout => 'content' } # updateParticipants.html.erb
      format.xml
    end
  end

end
