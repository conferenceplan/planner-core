class PendingImportPeopleController < PlannerController
  require 'csv'

  def index
    limit = params[:limit] ? params[:limit].to_i : nil
    offset = params[:offset] ? params[:offset].to_i : nil

    sort_by = params[:sort] ? params[:sort] : 'last_name'
    sort_order = params[:order] ? params[:order] : 'desc'

    @total = PendingImportPerson.count
    
    @pendingImportPeople = PendingImportPerson.offset(offset).limit(limit).order(sort_by + ' ' + sort_order)
  end
  
  def get_possible_matches
    pending_id = params[:pending_id]
    
    @matches = ImportService.getPossibleMatches(pending_id)
    @total = @matches.size
  end
  
  def merge_all_pending
    begin
      PendingImportPerson.transaction do
        ImportService.mergeAllPending
        render json: ['sucess'], :content_type => 'application/json'
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  def merge_pending
    begin
      PendingImportPerson.transaction do
        pending_id = params[:pending_id]
        person_id = params[:person_id]
    
        ImportService.mergePending pending_id, person_id
        render json: ['sucess'], :content_type => 'application/json'        
      end
    # rescue => ex
      # render status: :bad_request, text: ex.message
    end
  end

  def create_from_pending
    begin
      PendingImportPerson.transaction do
        pending_id = params[:pending_id]
    
        ImportService.newFromPending pending_id
        render json: ['sucess'], :content_type => 'application/json'
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
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
      PendingImportPerson.transaction do
        pendingImportPerson = PendingImportPerson.find(params[:id])
        pendingImportPerson.update_attributes(params[:pending_import_person])
        render json: pendingImportPerson.to_json, :content_type => 'application/json'
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end
  
  def destroy
    begin
      PendingImportPerson.transaction do
        pendingImportPerson = PendingImportPerson.find(params[:id])
        pendingImportPerson.destroy
        render status: :ok, text: {}.to_json
      end
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
      ignore_first_line = params[:ignore_first] ? params[:ignore_first] : false
  
      mapping = ImportMapping.where(datasource_id: datasource_id).first # how the CSV is mapped to columns
      
      # Put all of the above into the Pending table and then use that to do the import
      ImportService.importCSVtoPending file, mapping, datasource_id, ignore_first_line
      
      # Process the pending table
      result = ImportService.processPendingImports datasource_id
      # result =       {
        # :created => 0,
        # :updates => 0,
        # :possible_matches => 0,
        # :registration_in_use => 0,
        # :possible_name_updates => 0
      # }

  
      # TODO - need to return a JSON result set listing how many imported and how many need review....
      render json: result.to_json, :content_type => 'application/json'
    rescue => ex
      logger.error ex.backtrace.join("\n")
      render status: :bad_request, text: ex.message
    end
  end

end
