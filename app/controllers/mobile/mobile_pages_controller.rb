class Mobile::MobilePagesController < ApplicationController
  def index
    pages = MobilePages.find :all, :order => 'position asc'
    
    render json: pages.to_json, :content_type => 'application/json'
  end

  def show
    page = MobilePages.find params[:id]
    
    render json: page.to_json, :content_type => 'application/json'
  end

  def create
    page = MobilePages.new params[:mobile_page]
    page.save!
    
    render json: page.to_json, :content_type => 'application/json'
  end

  def update
    page = MobilePages.find params[:id]
    page.update_attributes params[:mobile_page]
    
    render json: page.to_json, :content_type => 'application/json'
  end

  def destroy
    candidate = MobilePages.find(params[:id])
    
    candidate.destroy
    render status: :ok, text: {}.to_json
  end
end
