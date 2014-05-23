class Items::ConfictExceptionsController < PlannerController

  def index
    exceptions = ConflictException.find :all
    
    render json: exceptions.to_json, :content_type => 'application/json'
  end
  
  def show
    exception = ConflictException.find params[:id]
    
    render json: exception.to_json, :content_type => 'application/json'
  end
  
  def create
    begin
      exception = ConflictException.new(params[:conflict_exception])
      
      exception.save!
      
      render json: exception.to_json, :content_type => 'application/json'
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end
  
  def destroy
    exception = ConflictException.find params[:id]
    
    begin
      exception.destroy
      render status: :ok, text: {}.to_json
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

end
