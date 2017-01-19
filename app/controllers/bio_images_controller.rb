class BioImagesController < PlannerController
  def index
    if (params[:person_id])
      person = Person.find(params[:person_id])

      bio_image = person.bio_image
    else
      bio_image = BioImage.find(params[:id])
    end
    
    render json: bio_image.to_json, :content_type => 'application/json'
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def show
    if (params[:person_id])
      person = Person.find(params[:person_id])

      bio_image = person.bio_image
    else
      bio_image = BioImage.find(params[:id])
    end

    render json: bio_image.to_json, :content_type => 'application/json'
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def create
    if (params[:person_id])
      person = Person.find(params[:person_id])
      bio_image = person.create_bio_image :bio_picture => params[:bio_picture]
      person.save!
    end # TODO - if no person should we return an error?
    
    bio_image.reload        
    render json: bio_image.to_json, :content_type => 'application/json'
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def update
    bio_image = BioImage.find(params[:id])
    
    bio_image.bio_picture = params[:bio_picture]
    bio_image.save!

    bio_image.reload        
    render json: bio_image.to_json, :content_type => 'application/json'
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def destroy
    bio_image = BioImage.find(params[:id])
    
    bio_image.destroy
    
    render status: :ok, text: {}.to_json
  rescue => ex
    render status: :bad_request, text: ex.message
  end
end
