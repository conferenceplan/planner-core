class SetupTypesController < ApplicationController
  def index
  end

  def list
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]

    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB
    @count = SetupType.count
    if rows.to_i > 0
      @nbr_pages = (@count / rows.to_i).floor + 1
    
      off = (@page.to_i - 1) * rows.to_i
      args = {:offset => off, :limit => rows, :order => idx + " " + order}
    end

    @setup_types = SetupType.find :all, args
   
    respond_to do |format|
      format.html { render :layout => 'plain' } # list.html.erb
      format.xml
    end
  end

  def show
    @setup_type = SetupType.find(params[:id])
  end

  def create
    @setup_type = SetupType.new(params[:setup_type])
    if (@setup_type.save)
       render :action => 'index', :layout => 'content'
    else
      render :content
    end 
  end

  def update
    @setup_type = SetupType.find(params[:id])
    if @setup_type.update_attributes(params[:setup_type])
      render :action => 'index', :layout => 'content'
    else
      render :action => 'edit', :layout => 'content'
    end
  end

  def destroy
    @setup_type = SetupType.find(params[:id])
    
    test = RoomSetup.find_by_setup_type_id(@setup_type.id)
    if test.nil?
      @setup_type.destroy
       render :action => 'index', :layout => 'content'
    else
      render :action => 'in_use', :layout => "plain"
    end
  end

   def picklist
     @setup_types = SetupType.find :all
     render :action => :list, :layout => "plain"
   end
end
