class EditedBiosController < PlannerController
  
  def update
    @editedBio = EditedBio.find(params[:id])
    
    @editedBio.update_attributes(permitted_params)
    @surveyBio = @editedBio.person.GetSurveyBio
  rescue => ex
    render status: :bad_request, text: ex.message
  end
  
  def create
    if (params[:person_id])
      @person = Person.find(params[:person_id]) 
      @editedBio = @person.create_edited_bio(permitted_params)
      @surveyBio = @person.GetSurveyBio
    else
      @editedBio = EditedBio.new(permitted_params)
      @surveyBio = @editedBio.person.GetSurveyBio
    end
    
    @editedBio.save!
  rescue => ex
    render status: :bad_request, text: ex.message
  end
  
  def show
    if (params[:person_id])
      @person = Person.find(params[:person_id])

      @editedBio = @person.edited_bio
      @surveyBio = @person.GetSurveyBio
    else
      @editedBio = EditedBio.find(params[:id])
      @surveyBio = @editedBio.person.GetSurveyBio
    end
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def index
    if (params[:person_id])
       @person = Person.find(params[:person_id])
       @editedBio = @person.edited_bio
       @surveyBio = @person.GetSurveyBio
    else
      @editedBio = EditedBio.find(params[:id])
      @surveyBio = @editedBio.person.GetSurveyBio
    end
  rescue => ex
    render status: :bad_request, text: ex.message
  end
  
  def destroy
    editedBio = EditedBio.find(params[:id])
    editedBio.destroy
    
    render status: :ok, text: {}.to_json
  end

  protected
  def permitted_params
    params.permit(
      EditedBio.globalize_attribute_names +
      EditedBio.sociable_attribute_names +
      [
        :lock_version, :person_id, :photourl, :bio
      ]
    )
  end
  
end
