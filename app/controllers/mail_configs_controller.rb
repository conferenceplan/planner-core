class MailConfigsController < PlannerController
  # GET /mail_configs
  # GET /mail_configs.xml
  def index
    @mail_configs = MailConfig.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mail_configs }
    end
  end

  # GET /mail_configs/1
  # GET /mail_configs/1.xml
  def show
    @mail_config = MailConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mail_config }
    end
  end

  # GET /mail_configs/new
  # GET /mail_configs/new.xml
  def new
    @mail_config = MailConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mail_config }
    end
  end

  # GET /mail_configs/1/edit
  def edit
    @mail_config = MailConfig.find(params[:id])
  end

  # POST /mail_configs
  # POST /mail_configs.xml
  def create
    @mail_config = MailConfig.new(params[:mail_config])

    respond_to do |format|
      if @mail_config.save
        format.html { redirect_to(@mail_config, :notice => 'MailConfig was successfully created.') }
        format.xml  { render :xml => @mail_config, :status => :created, :location => @mail_config }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mail_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mail_configs/1
  # PUT /mail_configs/1.xml
  def update
    @mail_config = MailConfig.find(params[:id])

    respond_to do |format|
      if @mail_config.update_attributes(params[:mail_config])
        format.html { redirect_to(@mail_config, :notice => 'MailConfig was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mail_config.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mail_configs/1
  # DELETE /mail_configs/1.xml
  def destroy
    @mail_config = MailConfig.find(params[:id])
    @mail_config.destroy

    respond_to do |format|
      format.html { redirect_to(mail_configs_url) }
      format.xml  { head :ok }
    end
  end
end
