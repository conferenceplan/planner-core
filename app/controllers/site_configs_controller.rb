class SiteConfigsController < PlannerController
  def index
    @site_configs = SiteConfig.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @site_configs }
    end
  end

  def show
    @site_config = SiteConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site_config }
    end
  end

  def new
    @site_config = SiteConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site_config }
    end
  end

  def edit
    @site_config = SiteConfig.find(params[:id])
  end
  
  def create
    @site_config = SiteConfig.new(params[:site_config])

    respond_to do |format|
      if @site_config.save
        format.html { redirect_to(@site_config, :notice => 'SiteConfig was successfully created.') }
        format.xml  { render :xml => @site_config, :status => :created, :location => @site_config }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @site_config = SiteConfig.find(params[:id])

    respond_to do |format|
      if @site_config.update_attributes(params[:site_config])
        format.html { redirect_to(@site_config, :notice => 'SiteConfig was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @site_config = SiteConfig.find(params[:id])
    @site_config.destroy

    respond_to do |format|
      format.html { redirect_to(site_configs_url) }
      format.xml  { head :ok }
    end
  end
end
