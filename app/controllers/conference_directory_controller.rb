class ConferenceDirectoryController < ApplicationController

  def index
    directory = ConferenceDirectory.find :all

    render json: directory.to_json(:except => [:created_at, :updated_at, :code]), :content_type => 'application/json'
  end
  
  def find_by_code
    code = params[:code]
    
    dir = ConferenceDirectory.where( :code => code ).first
    
    
    render json: dir.to_json(:except => [:created_at, :updated_at, :code]), :content_type => 'application/json'
  end
  
  def find_by_id
    dir = ConferenceDirectory.find(params[:id])
    
    render json: dir.to_json(:except => [:created_at, :updated_at, :code]), :content_type => 'application/json'
  end
  
  #
  #
  #
  def show
    dir = ConferenceDirectory.find(params[:id])
    
    render json: dir.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def create
    dir = ConferenceDirectory.new params[:conference_directory] # TODO - check
    dir.save!
    
    render json: dir.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def update
    dir = ConferenceDirectory.find params[:id]
    dir.update_attributes params[:conference_directory]
    
    render json: dir.to_json, :content_type => 'application/json'
  end

  #
  #
  #  
  def destroy
    dir = ConferenceDirectory.find(params[:id])

    begin
      dir.destroy
      render status: :ok, text: {}.to_json
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

end
