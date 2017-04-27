class FormatsController < PlannerController
  
  def list  
    # Get all the formats in the database
    @formats = Format.all.order('position asc')
    render :layout => 'plain'
  end
  
  def listwithblank
    # Get all the formats in the database
    @formats = Format.all.order('position asc')
    render :layout => 'content'
  end

  def index
    if params[:search].present?
      @formats = Format.where(["name like ?", ("%" + params[:search] + "%")]).order('position asc')
    else
      @formats = Format.all.order('position asc')
    end
  end

  def create
    last_pos = Format.pluck(:position).compact.max || 0
    position = params[:position] || (last_pos + 1)
    @format = Format.create(
      name: params[:name],
      position: position
    )
  end

  def update
    @format = Format.find params[:id]
    if @format
      @format.name = params[:name]
      @format.position = params[:position]
      @format.save!
    end
  end

  def show
    @format = Format.find params[:id]
  end

  def destroy
    format = Format.find params[:id]
    format.delete
    render status: :ok, text: {}.to_json
  end

end
