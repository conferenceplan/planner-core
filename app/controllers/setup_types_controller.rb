class SetupTypesController < ApplicationController
  
  #
  #
  #
  def index
    if params[:search].present?
      setup_types = SetupType.where(["name like ?", ("%" + params[:search] + "%")])
    else
      setup_types = SetupType.all
    end
    
    render json: setup_types.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def show
    setup_type = SetupType.find(params[:id])
    
    render json: setup_type.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def create
    setup_type = SetupType.new(params[:setup_type])
    setup_type.save!

    render json: setup_type.to_json, :content_type => 'application/json'
  end

  #
  #
  #
  def update
    setup_type = SetupType.find(params[:id])
    setup_type.update_attributes(params[:setup_type])
    
    render json: setup_type.to_json, :content_type => 'application/json'
  end

  #
  #
  #
  def destroy
    candidate = SetupType.find(params[:id])
    
    test = RoomSetup.find_by_setup_type_id(candidate.id)
    if test.nil?
      candidate.destroy
      render status: :ok, text: {}.to_json
    else
      render status: :bad_request, text: 'Can not delete setup associated with a room'
    end
  end

  #
  #
  #
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

      @setup_types = SetupType.all.offset(off).limit(rows).order(idx + " " + order)
    else
      @setup_types = SetupType.all
    end

    respond_to do |format|
      format.html { render :layout => 'plain' } # list.html.erb
      format.xml
    end
  end

   def picklist
     @setup_types = SetupType.all
     render :action => :picklist, :layout => "plain"
   end
end
