class ExternalImagesController < PlannerController
  def index
    if (params[:cid]) # the type of the 'parent' and it's id are passed in via cname nd cid
      className = params[:cname]
      images = eval(className).find(params[:cid]).external_images
    else
      images = ExternalImage.find :all
    end
    
    render json: images.to_json, :content_type => 'application/json'
  end

  def show
    if (params[:cid]) # the type of the 'parent' and it's id are passed in via cname nd cid
      className = params[:cname]
      image = eval(className).find(params[:cid]).external_images.use(params[:use])
    else
      image = ExternalImage.find params[:id]
    end
    
    render json: image.to_json, :content_type => 'application/json'
  end

  def create
    if (params[:cid]) # the type of the 'parent' and it's id are passed in via cname nd cid
      className = params[:cname]
      parent = eval(className).find(params[:cid])
      
      # image = ExternalImage.new params[:external_image]

      image = parent.external_images.new :picture => params[:picture] ########
      image.use = params[:use]
      image.save!
      parent.save!
    else
      image = ExternalImage.new(params[:picture])
      image.use = params[:use]
      image.save!
    end
    
    render json: image.to_json, :content_type => 'application/json'
  end

  def update
    if (params[:cid]) # the type of the 'parent' and it's id are passed in via cname nd cid
      className = params[:cname]
      parent = eval(className).find(params[:cid])
      image = parent.external_images.use(params[:use])
      image[0].picture = params[:picture]
      image[0].save!
    else
      image = ExternalImage.find(params[:id])
      image.picture = params[:picture]
      image.save!
    end
    
    render json: image.to_json, :content_type => 'application/json'
  end

  def destroy
    image = ExternalImage.find(params[:id])
    
    image.destroy
    
    render status: :ok, text: {}.to_json
  end
end
