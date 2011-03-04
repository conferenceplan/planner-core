class SurveyCopyStatusesController < PlannerController
  
  # GET /survey_copy_statuses
  # GET /survey_copy_statuses.xml
  def index
    @survey_copy_statuses = SurveyCopyStatus.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @survey_copy_statuses }
    end
  end

  # GET /survey_copy_statuses/1
  # GET /survey_copy_statuses/1.xml
  def show
    @survey_copy_status = SurveyCopyStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @survey_copy_status }
    end
  end

  # GET /survey_copy_statuses/new
  # GET /survey_copy_statuses/new.xml
  def new
    @survey_copy_status = SurveyCopyStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @survey_copy_status }
    end
  end

  # GET /survey_copy_statuses/1/edit
  def edit
    @survey_copy_status = SurveyCopyStatus.find(params[:id])
  end

  # POST /survey_copy_statuses
  # POST /survey_copy_statuses.xml
  def create
    @survey_copy_status = SurveyCopyStatus.new(params[:survey_copy_status])

    respond_to do |format|
      if @survey_copy_status.save
        format.html { redirect_to(@survey_copy_status, :notice => 'SurveyCopyStatus was successfully created.') }
        format.xml  { render :xml => @survey_copy_status, :status => :created, :location => @survey_copy_status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @survey_copy_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /survey_copy_statuses/1
  # PUT /survey_copy_statuses/1.xml
  def update
    @survey_copy_status = SurveyCopyStatus.find(params[:id])

    respond_to do |format|
      if @survey_copy_status.update_attributes(params[:survey_copy_status])
        format.html { redirect_to(@survey_copy_status, :notice => 'SurveyCopyStatus was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @survey_copy_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /survey_copy_statuses/1
  # DELETE /survey_copy_statuses/1.xml
  def destroy
    @survey_copy_status = SurveyCopyStatus.find(params[:id])
    @survey_copy_status.destroy

    respond_to do |format|
      format.html { redirect_to(survey_copy_statuses_url) }
      format.xml  { head :ok }
    end
  end
end
