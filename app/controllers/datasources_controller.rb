class DatasourcesController < ApplicationController
   def index
      @datasources = Datasource.find :all
   end

   def list
     @datasources = Datasource.find :all
     render :action => :list, :layout => "plain"
   end

   def show
      @datasource = Datasource.find params[:id]
   end
   def new
      @datasource = Datasource.new
   end
   def create
      @datasource = Datasource.new params[:datasource]
      if @datasource.save
         redirect_to :action => 'index'
      else
         render :action => 'new'
      end
   end
   def edit
      @datasource = Datasource.find params[:id]
   end
   def update
      @datasource = Datasource.find params[:id]
      if @datasource.update_attributes params[:datasource]
         redirect_to :action => 'index'
      else
         render :action => 'edit'
      end
   end
   def destroy
      @peoplesources = Peoplesource.find_by_datasource_dbid(params[:id])
      if (@peoplesources.blank?)
         Datasource.find(params[:id]).destroy
      end
      redirect_to :action => 'index'
   end
end
