class InvitationCategoriesController < PlannerController

  def index
    @invitationCategories = InvitationCategory.find :all
  end
  def show
    @invitationCategory = InvitationCategory.find(params[:id])
  end
  def create
    @invitationCategory = InvitationCategory.new(params[:invitation_category])
    if (@invitationCategory.save)
       redirect_to :action => 'show', :id => @invitationCategory
    else
      render :action => 'new'
    end 
  end
  def new
    @invitationCategory = InvitationCategory.new
  end
  
  def edit
    @invitationCategory = InvitationCategory.find(params[:id])
  end
  
  def update
    @invitationCategory = InvitationCategory.find(params[:id])
    if @invitationCategory.update_attributes(params[:invitation_category])
      redirect_to :action => 'show', :id => @invitationCategory
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @invitationCategory = InvitationCategory.find(params[:id])
    @invitationCategory.destroy
    redirect_to :action => 'index'
  end
  def list  
    # Get all the roles in the database
    @invitationCategories = InvitationCategory.find :all
    render :layout => 'content'
  end
end
