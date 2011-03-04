class EditedBiosController < PlannerController

  def index
    @editedBios = EditedBio.find :all
  end
  
  def show
    if (params[:person_id])
       @person = Person.find(params[:person_id])
       @urlstr = '/participants/'+ params[:person_id]  + '/edited_bio/new'

       @editedBio = @person.edited_bio
       @surveyBio = @person.GetSurveyBio
    else
      @urlstr = '/edited_bios/new'

      @editedBio = EditedBio.find(params[:id])
      @surveyBio = @editedBio.person.GetSurveyBio
    end
    
    render :layout => 'content'
  end
  
  def create
    
    if (params[:person_id])
      @person = Person.find(params[:person_id]) 
      @editedBio = @person.create_edited_bio(params[:edited_bio]);
    else
      @editedBio = EditedBios.new(params[:edited_bio])
    end
    
    if (@editedBio.save)
#      We want to go back to?
          redirect_to :action => 'show', :id => @editedBio
    else
         render :action => 'new'
    end

end
  
  def new
     if (params[:person_id])
      @urlstr = '/participants/' + params[:person_id] + '/edited_bio'
    else
      @urlstr = '/edited_bios'
    end
    @editedBio = EditedBio.new
    person = Person.find(params[:person_id])
    @editedBio.bio = person.GetSurveyBio
    render :layout => 'content'
  end
  
  def edit
    @editedBio = EditedBio.find(params[:id])
    @urlstr = '/edited_bios/' + params[:id]
    render :layout => 'content'
  end
  
  def update

    @editedBio = EditedBio.find(params[:id])
    if @editedBio.update_attributes(params[:edited_bio])
      redirect_to :action => 'show', :id => @editedBio
    else
      render :action => 'edit'
    end
    
  end
  
  def destroy
    @editedBio = EditedBio.find(params[:id])
    @editedBio.destroy
    redirect_to :action => 'index'
  end
  
end

