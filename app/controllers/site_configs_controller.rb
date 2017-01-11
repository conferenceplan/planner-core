class SiteConfigsController < PlannerController
  def index
    site_config = SiteConfig.first
    
    if site_config
      site_config.start_date  = Date.today if !site_config.start_date
    end
    
    render json: site_config.to_json, :content_type => 'application/json'
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def show
    site_config = SiteConfig.find(params[:id])

    if site_config
      site_config.start_date  = Date.today if !site_config.start_date
    end
    
    render json: site_config.to_json, :content_type => 'application/json'
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def create
    site_config = SiteConfig.new(params[:site_config])
    day = Time.zone.parse(params[:start_date]).day
    
    # Make sure we use the selected time-zone of the convention
    Time.use_zone(site_config.time_zone) do 
      site_config.save!
      
      site_config.tz_offset = site_config.start_date.utc_offset/60
    end

    render json: site_config.to_json(:methods => [:tz_offset]), :content_type => 'application/json'
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def update
    site_config = SiteConfig.find(params[:id])
    site_config.update_attributes(params[:site_config])
    day = Time.zone.parse(params[:start_date]).day
    
    # Make sure we use the selected time-zone of the convention
    Time.use_zone(site_config.time_zone) do 
      site_config.save!
      
      site_config.tz_offset = site_config.start_date.utc_offset/60
    end
    
    render json: site_config.to_json(:methods => [:tz_offset]), :content_type => 'application/json'
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def destroy
    site_config = SiteConfig.find(params[:id])
    site_config.destroy

    render status: :ok, text: {}.to_json
  rescue => ex
    render status: :bad_request, text: ex.message
  end
end
