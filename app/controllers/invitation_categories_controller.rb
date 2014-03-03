class InvitationCategoriesController < PlannerController

  #
  #
  #
  def index
    invitationCategories = InvitationCategory.find :all, :order => 'position asc'
    
    render json: invitationCategories.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def show
    invitationCategory = InvitationCategory.find(params[:id])
    
    render json: invitationCategory.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def create
    invitationCategory = InvitationCategory.new(params[:invitation_category])
    invitationCategory.save!

    render json: invitationCategory.to_json, :content_type => 'application/json'
  end

  #
  #
  #
  def update
    invitationCategory = InvitationCategory.find(params[:id])
    invitationCategory.update_attributes(params[:invitation_category])
    
    render json: invitationCategory.to_json, :content_type => 'application/json'
  end
  
  def destroy
    candidate = InvitationCategory.find(params[:id])
    
    begin
      candidate.destroy
      render status: :ok, text: {}.to_json
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end
  
  def list  
    # Get all the roles in the database
    @invitationCategories = InvitationCategory.find :all, :order => 'position asc'
    render :layout => 'plain'
  end
end
