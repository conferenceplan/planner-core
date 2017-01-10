class CloudinaryConfigController < PlannerController
  #
  #
  #
  def index
    # TODO - when we have multi-tenant base this on the current convention...
    cloud_config = CloudinaryConfig.first
    
    render json: cloud_config.to_json, :content_type => 'application/json'
  end

  def show
    cloud_config = CloudinaryConfig.find(params[:id])

    render json: cloud_config.to_json, :content_type => 'application/json'
  end

  def create
    cloud_config = CloudinaryConfig.new params[:cloudinary_config]
    cloud_config.save!

    render json: cloud_config.to_json, :content_type => 'application/json'
  end

  def update
    cloud_config = CloudinaryConfig.find(params[:id])
    cloud_config.update_attributes(params[:cloudinary_config])

    render json: cloud_config.to_json, :content_type => 'application/json'
  end

  def destroy
    cloud_config = CloudinaryConfig.find(params[:id])
    cloud_config.destroy

    render status: :ok, text: {}.to_json
  end
end
