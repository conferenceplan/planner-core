class ProgrammeItemsController < ApplicationController

  def index
    @programmeItems = ProgrammeItem.find :all
  end
  def show
    @programmeItem = ProgrammeItem.find(params[:id])
  end
  def create
    @programmeItem = ProgrammeItem.new(params[:programme_item])
    if (@programmeItem.save)
       redirect_to :action => 'show', :id => @programmeItem
    else
      render :action => 'new'
    end 
  end
  def new
    @programmeItem = ProgrammeItem.new
  end
  
  def edit
    @programmeItem = ProgrammeItem.find(params[:id])
  end
  
  def update
    @programmeItem = ProgrammeItem.find(params[:id])
    if @programmeItem.update_attributes(params[:programme_item])
      redirect_to :action => 'show', :id => @programmeItem
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @programmeItem = ProgrammeItem.find(params[:id])
    @programmeItem.destroy
    redirect_to :action => 'index'
  end
  #
  
  def list
    j = ActiveSupport::JSON
    
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]
    clause = ""
    fields = Array::new
    
    if (params[:filters])
      queryParams = j.decode(params[:filters])
      if (queryParams)
        clausestr = ""
        queryParams["rules"].each do |subclause|
          if clausestr.length > 0 
            clausestr << ' ' + queryParams["groupOp"] + ' '
          end
          if subclause["op"] == 'ne'
            clausestr << subclause['field'] + ' not like ?'
          else
            clausestr << subclause['field'] + ' like ?'
          end
          fields << subclause['data'] + '%'
          logger.info fields
        end
        clause = [clausestr] | fields
      end
    end
    
    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB
    count = ProgrammeItem.count :conditions => clause
    @nbr_pages = (count / rows.to_i).floor + 1
    
    off = (@page.to_i - 1) * rows.to_i
    @programmeItems = ProgrammeItem.find :all, :offset => off, :limit => rows,
      :order => idx + " " + order, :conditions => clause
   
    # We return the list of ProgrammeItems as an XML structure which the 'table' can use.
    # TODO: would it be more efficient to use JSON instead?
    respond_to do |format|
      format.xml
    end
  end

end
