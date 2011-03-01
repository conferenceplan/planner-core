class FormatsController < PlannerController
  before_filter :require_user

  def index
    @formats = Format.find :all
  end
  def show
    @format = Format.find(params[:id])
  end
  def create
    @format = Format.new(params[:format])
    if (@format.save)
       redirect_to :action => 'index'
    else
      render :action => 'new'
    end 
  end
  def new
    @format = Format.new
  end
  
  def edit
    @format = Format.find(params[:id])
  end
  
  def update
    @format = Format.find(params[:id])
    if @format.update_attributes(params[:format])
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @format = Format.find(params[:id])
    @format.destroy
    redirect_to :action => 'index'
  end
  def list  
    # Get all the formats in the database
    @formats = Format.find :all
    render :layout => 'content'
  end
  
  def listwithblank
    # Get all the formats in the database
    @formats = Format.find :all
    render :layout => 'content'
  end
end
