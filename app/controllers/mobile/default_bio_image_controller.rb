class Mobile::DefaultBioImageController < PlannerController
  def index
    image = DefaultBioImage.find :first
    
    # if one does not exist then create it??
    
    render json: image.to_json, :content_type => 'application/json'
  end

  def show
    image = DefaultBioImage.find params[:id]
    
    render json: image.to_json, :content_type => 'application/json'
  end

  def create
    image = DefaultBioImage.new 
    image.image = params[:default_bio_image]
    image.save!
    
    render json: image.to_json, :content_type => 'application/json'
  end

  def update
    image = DefaultBioImage.find params[:id]
    image.image = params[:default_bio_image]
    image.save!
    
    render json: image.to_json, :content_type => 'application/json'
  end

  def destroy
    candidate = DefaultBioImage.find(params[:id])
    
    candidate.destroy
    render status: :ok, text: {}.to_json
  end
end
