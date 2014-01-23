class EditedBiosController < PlannerController
  
  def update
    editedBio = EditedBio.find(params[:id])
    
    editedBio.update_attributes(params[:edited_bio])

    render json: editedBio.to_json, :content_type => 'application/json'
  end
  
  def create
    if (params[:person_id])
      person = Person.find(params[:person_id]) 
      editedBio = person.create_edited_bio(params[:edited_bio]);
    else
      editedBio = EditedBios.new(params[:edited_bio])
    end
    
    editedBio.save

    render json: editedBio.to_json, :content_type => 'application/json'
  end
  
  def show
    if (params[:person_id])
      person = Person.find(params[:person_id])

      @editedBio = person.edited_bio
      @surveyBio = @person.GetSurveyBio
    else
      @editedBio = EditedBio.find(params[:id])
      @surveyBio = @editedBio.person.GetSurveyBio
    end
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
  end
  
  def destroy
    editedBio = EditedBio.find(params[:id])
    editedBio.destroy
    
    render status: :ok, text: {}.to_json
  end
  
  def exportbiolist
    exportSelect = params[:selectExportBioList][:export_select]
    accepted = AcceptanceStatus.find_by_name("Accepted")        
    invitestatus = InviteStatus.find_by_name("Invited")
    
    # TODO - these need to be checked and made more rational
    if (exportSelect == 'true')
       updatedValueYear = params[:selectExportBioList]['updated_at(1i)']
       updatedValueMon = params[:selectExportBioList]['updated_at(2i)']
       updatedValueDay = params[:selectExportBioList]['updated_at(3i)']
       updatedValueHour = params[:selectExportBioList]['updated_at(4i)']
       updatedValueMinute = params[:selectExportBioList]['updated_at(5i)']
       updatedValueSecond = params[:selectExportBioList]['updated_at(5i)']    
       updateValue = Time.zone.local(updatedValueYear,updatedValueMon,updatedValueDay,updatedValueHour,updatedValueMinute,updatedValueSecond)
    
       @editedBios = EditedBio.find :all, :include => {:person => :pseudonym}, :conditions => ['people.acceptance_status_id = ? and people.invitestatus_id = ? and edited_bios.updated_at > ?', accepted.id, invitestatus.id, updateValue], :order => 'people.last_name, people.first_name'
    else
       @editedBios = EditedBio.find :all, :include => {:person => :pseudonym}, :conditions => ['people.acceptance_status_id = ? and people.invitestatus_id = ?', accepted.id, invitestatus.id], :order => 'people.last_name, people.first_name'
    end
    render :layout => 'content'
  end
  
end
