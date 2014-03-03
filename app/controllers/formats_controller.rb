class FormatsController < PlannerController
  
  #
  #
  #
  def index
    @formats = Format.find :all, :order => 'position asc'
  end
  
  #
  #
  #
  def show
    @format = Format.find(params[:id])
  end
  
  #
  #
  #
  def create
    @format = Format.new(params[:format])
    @format.save!
  end
  
  #
  #
  #
  def update
    @format = Format.find(params[:id])
    @format.update_attributes(params[:format])
  end

  #
  #
  #  
  def destroy
    format = Format.find(params[:id])

    begin
      format.destroy
      render status: :ok, text: {}.to_json
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

########  
  def list  
    # Get all the formats in the database
    @formats = Format.find :all, :order => 'position asc'
    render :layout => 'plain'
  end
  
  def listwithblank
    # Get all the formats in the database
    @formats = Format.find :all , :order => 'position asc'
    render :layout => 'content'
  end
end
