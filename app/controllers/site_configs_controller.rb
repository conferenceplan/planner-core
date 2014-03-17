class SiteConfigsController < PlannerController
  def index
    # TODO - when we have multi-tenant base this on the current convention...
    site_config = SiteConfig.find :first
    
    if site_config
      site_config.start_date  = Date.today if !site_config.start_date
    end
    
    site_config.languages = UISettingsService.getLanguages
    
    render json: site_config.to_json( :methods => [:languages] ), :content_type => 'application/json'
  end

  def show
    site_config = SiteConfig.find(params[:id])

    if site_config
      site_config.start_date  = Date.today if !site_config.start_date
    end
    
    site_config.languages = UISettingsService.getLanguages
    
    render json: site_config.to_json( :methods => [:languages] ), :content_type => 'application/json'
  end

  def create
    site_config = SiteConfig.new(params[:site_config])
    site_config.start_date = site_config.start_date.change({:hour => 0 , :min => 0 , :sec => 0 })
    site_config.save!

    UISettingsService.setLanguages params[:languages].split(',')
    site_config.languages = UISettingsService.getLanguages

    render json: site_config.to_json( :methods => [:languages] ), :content_type => 'application/json'
  end

  def update
    site_config = SiteConfig.find(params[:id])
    site_config.update_attributes(params[:site_config])
    site_config.start_date = site_config.start_date.change({:hour => 0 , :min => 0 , :sec => 0 })
    
    UISettingsService.setLanguages params[:languages].split(',')
    site_config.languages = UISettingsService.getLanguages

    render json: site_config.to_json( :methods => [:languages] ), :content_type => 'application/json'
  end

  def destroy
    site_config = SiteConfig.find(params[:id])
    site_config.destroy

    render status: :ok, text: {}.to_json
  end
end
