class PendingImportPeopleController < PlannerController
  require 'csv'

  def index
    pendingImportPeople = PendingImportPerson.find :all, :order => :last_name

    render json: pendingImportPeople.to_json, :content_type => 'application/json'
  end
  
  def show
    pendingImportPerson = PendingImportPerson.find(params[:id])
    
    render json: pendingImportPerson.to_json, :content_type => 'application/json'
  end
  
  def create
    begin
      pendingImportPerson = PendingImportPerson.new(params[:pending_import_person])
      pendingImportPerson.save!
      render json: pendingImportPerson.to_json, :content_type => 'application/json'
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  def update
    begin
      pendingImportPerson = PendingImportPerson.find(params[:id])
      pendingImportPerson.update_attributes(params[:pending_import_person])
      render json: pendingImportPerson.to_json, :content_type => 'application/json'
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end
  
  def destroy
    begin
      pendingImportPerson = PendingImportPerson.find(params[:id])
      pendingImportPerson.destroy
      render status: :ok, text: {}.to_json
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end
  
  #
  #
  #
  def import_file
    begin
      # Temporary Import from CSV file
      file = "/tmp/" + params[:file] # "/tmp/" + file
      datasource_id = params[:datasource_id]
      # we also want a flag to indicate whether we want to skip the first line
      ignore_first_line = false
  
      mapping = ImportMapping.where(datasource_id: datasource_id).first # how the CSV is mapped to columns
      
      # Put all of the above into the Pending table and then use that to do the import
      ImportService.importCSVtoPending file, mapping, datasource_id, ignore_first_line
      
      # Process the pending table
      result = ImportService.processPendingImports datasource_id
  
      # TODO - need to return a JSON result set listing how many imported and how many need review....
      render json: result.to_json, :content_type => 'application/json'
    rescue => ex
      logger.error ex.backtrace.join("\n")
      render status: :bad_request, text: ex.message
    end
  end

end
