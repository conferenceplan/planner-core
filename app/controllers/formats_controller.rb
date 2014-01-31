class FormatsController < PlannerController
  
  #
  #
  #
  def index
    formats = Format.find :all, :order => 'position asc'
    
    render json: formats.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def show
    format = Format.find(params[:id])
    
    render json: format.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def create
    format = Format.new(params[:format])
    format.save!
    
    render json: format.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def update
    format = Format.find(params[:id])
    format.update_attributes(params[:format])

    render json: format.to_json, :content_type => 'application/json'
  end

  #
  #
  #  
  def destroy
    format = Format.find(params[:id])
    
    # prevent delete of formats that are in use
    if format.programme_items.size > 0
      render status: :bad_request, text: 'Can not delete format associated with program items'
    else  
      format.destroy
      render status: :ok, text: {}.to_json
    end
  end

########  
  def list  
    # Get all the formats in the database
    @formats = Format.find :all
    render :layout => 'plain'
  end
  
  def listwithblank
    # Get all the formats in the database
    @formats = Format.find :all
    render :layout => 'content'
  end
end
