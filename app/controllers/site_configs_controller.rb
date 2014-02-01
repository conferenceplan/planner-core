class SiteConfigsController < PlannerController
  def index
    # TODO - when we have multi-tenant base this on the current convention...
    site_config = SiteConfig.find :first
    
    render json: site_config.to_json, :content_type => 'application/json'
  end

  def show
    site_config = SiteConfig.find(params[:id])

    render json: site_config.to_json, :content_type => 'application/json'
  end

  def create
    site_config = SiteConfig.new(params[:site_config])
    site_config.save!

    render json: site_config.to_json, :content_type => 'application/json'
  end

  def update
    site_config = SiteConfig.find(params[:id])
    site_config.update_attributes(params[:site_config])

    render json: site_config.to_json, :content_type => 'application/json'
  end

  def destroy
    site_config = SiteConfig.find(params[:id])
    site_config.destroy

    render status: :ok, text: {}.to_json
  end
end
