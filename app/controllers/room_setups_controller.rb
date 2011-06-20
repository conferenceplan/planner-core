class RoomSetupsController < ApplicationController
  def index
  end

  def list
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]
    room_id = params[:room_id]

    args = {:conditions => {:room_id => room_id}}
    
    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB

    @count = RoomSetup.count(args)
    if rows.to_i > 0
      @nbr_pages = (@count / rows.to_i).floor + 1
    
      off = (@page.to_i - 1) * rows.to_i
      args.merge!(:offset => off, :limit => rows, :order => idx + " " + order)
    end

    @room_setups = RoomSetup.find :all, args
   
    respond_to do |format|
      format.html { render :layout => 'plain' } # list.html.erb
      format.xml
    end
  end

  def show
Rails.logger.debug params
    @room_setup = RoomSetup.find(params[:id])
  end

  def create
    @room_setup = RoomSetup.new(params[:room_setups])
     if (@room_setup.save)
      render :action => 'index', :layout => 'content'
    else
      render :content
    end 
 end

  def update
    @room_setup = RoomSetup.find(params[:id])
    if @room_setup.update_attributes(params[:room_setups])
      render :action => 'index', :layout => 'content'
    else
      render :action => 'edit', :layout => 'content'
    end
  end

  def destroy
    @room_setup = RoomSetup.find(params[:id])
    test = Room.find_by_setup_type_id(@room_setup.id)
    if test.nil?
      @room_setup.destroy
      render :action => 'index', :layout => 'content'
    else
      render :action => 'index', :layout => 'content'
    end  
  end
end
