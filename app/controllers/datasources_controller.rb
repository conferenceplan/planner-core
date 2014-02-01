class DatasourcesController < ApplicationController
  
  #
  #
  #
  def index
    datasources = Datasource.find :all
    
    render json: datasources.to_json, :content_type => 'application/json'
  end

  def show
    datasource = Datasource.find params[:id]
    
    render json: datasource.to_json, :content_type => 'application/json'
  end
  
  def create
    datasource = Datasource.new params[:datasource]
    datasource.save

    render json: datasource.to_json, :content_type => 'application/json'
  end
  
  def update
    datasource = Datasource.find params[:id]
    datasource.update_attributes params[:datasource]
    
    render json: datasource.to_json, :content_type => 'application/json'
  end
  
  def destroy
    peoplesources = Peoplesource.find_by_datasource_dbid(params[:id])
    if (!peoplesources.blank?)
      Datasource.find(params[:id]).destroy
      render status: :ok, text: {}.to_json
    else
      render status: :bad_request, text: 'Can not delete datasource'
    end
  end
   
  def list
    @datasources = Datasource.find :all
    render :action => :list, :layout => "plain"
  end

end
