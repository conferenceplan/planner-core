class MailTemplatesController < PlannerController
  # GET /mail_templates
  # GET /mail_templates.xml
  def index
    @mail_templates = MailTemplate.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mail_templates }
    end
  end

  # GET /mail_templates/1
  # GET /mail_templates/1.xml
  def show
    @mail_template = MailTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mail_template }
    end
  end

  # GET /mail_templates/new
  # GET /mail_templates/new.xml
  def new
    @mail_template = MailTemplate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mail_template }
    end
  end

  # GET /mail_templates/1/edit
  def edit
    @mail_template = MailTemplate.find(params[:id])
  end

  # POST /mail_templates
  # POST /mail_templates.xml
  def create
    @mail_template = MailTemplate.new(params[:mail_template])

    respond_to do |format|
      if @mail_template.save
        format.html { redirect_to(@mail_template, :notice => 'MailTemplate was successfully created.') }
        format.xml  { render :xml => @mail_template, :status => :created, :location => @mail_template }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mail_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mail_templates/1
  # PUT /mail_templates/1.xml
  def update
    @mail_template = MailTemplate.find(params[:id])

    respond_to do |format|
      if @mail_template.update_attributes(params[:mail_template])
        format.html { redirect_to(@mail_template, :notice => 'MailTemplate was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mail_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mail_templates/1
  # DELETE /mail_templates/1.xml
  def destroy
    @mail_template = MailTemplate.find(params[:id])
    @mail_template.destroy

    respond_to do |format|
      format.html { redirect_to(mail_templates_url) }
      format.xml  { head :ok }
    end
  end
end
