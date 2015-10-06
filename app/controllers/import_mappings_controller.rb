class ImportMappingsController < ApplicationController
  require 'csv'
  
  #
  #
  #
  def index
    datasource_id = params[:datasource_id]
    if datasource_id
      mappings = ImportMapping.where(datasource_id: datasource_id).first
    else  
      mappings = ImportMapping.find :all
    end

    render json: mappings.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def columns
    file = params[:file]
    
    # read the first row of the file and return as an array of columns....
    if file && !file.empty?
      cols = nil
      csv_text = File.read("/tmp/" + file).encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
      csv = CSV.parse(csv_text, headers: false)
      csv.each do |row|
        cols = row
        break # just get the first row
      end
      
      p = -1;
      render json: cols.collect{|m| 
          p += 1
          {:posn => p, :name => m} 
        }.to_json, :content_type => 'application/json'
    else
      render json: {}.to_json, :content_type => 'application/json'
    end
  end
  
  #
  #
  #
  def show
    mapping = ImportMapping.find(params[:id])
    
    render json: mapping.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def create
    mapping = ImportMapping.new params[:import_mapping]
    mapping.save!
    
    render json: mapping.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def update
    mapping = ImportMapping.find params[:id]
    mapping.update_attributes params[:import_mapping]
    
    render json: mapping.to_json, :content_type => 'application/json'
  end

  #
  #
  #  
  def destroy
    mapping = ImportMapping.find(params[:id])

    begin
      mapping.destroy
      render status: :ok, text: {}.to_json
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

end
