class BioImagesController < ApplicationController
  def index
    if (params[:person_id])
      person = Person.find(params[:person_id])

      bio_image = person.bio_image
    else
      bio_image = BioImage.find(params[:id])
    end
    
    render json: bio_image.to_json, :content_type => 'application/json'
  end

  def show
    if (params[:person_id])
      person = Person.find(params[:person_id])

      bio_image = person.bio_image
    else
      bio_image = BioImage.find(params[:id])
    end
        
    render json: bio_image.to_json, :content_type => 'application/json'
  end

  def create
    if (params[:person_id])
      person = Person.find(params[:person_id])
      bio_image = person.create_bio_image :bio_picture => params[:bio_picture]
      person.save!
    end # TODO - if no person should we return an error?
    
    render json: bio_image.to_json, :content_type => 'application/json'
  end

  def update
    bio_image = BioImage.find(params[:id])
    
    bio_image.bio_picture = params[:bio_picture]
    bio_image.save!

    render json: bio_image.to_json, :content_type => 'application/json'
  end

  def destroy
    bio_image = BioImage.find(params[:id])
    
    bio_image.destroy
    
    render status: :ok, text: {}.to_json
  end
end
