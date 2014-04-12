class Mobile::LogoImagesController < PlannerController
  def index
    image = ConferenceLogo.find :first
    
    render json: image.to_json, :content_type => 'application/json'
  end

  def show
    image = ConferenceLogo.find params[:id]
    
    render json: image.to_json, :content_type => 'application/json'
  end

  def create
    image = ConferenceLogo.new 
    image.image = params[:conference_logo]
    image.save!
    
    render json: image.to_json, :content_type => 'application/json'
  end

  def update
    image = ConferenceLogo.find params[:id]
    image.image = params[:conference_logo]
    image.save!
    
    render json: image.to_json, :content_type => 'application/json'
  end

  def destroy
    candidate = ConferenceLogo.find(params[:id])
    
    candidate.destroy
    render status: :ok, text: {}.to_json
  end
end
