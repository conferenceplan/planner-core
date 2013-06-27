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
    @editedBio.website = SurveyService.getValueOfMappedQuestion(person, QuestionMapping['WebSite'])
    @editedBio.twitterinfo = SurveyService.getValueOfMappedQuestion(person, QuestionMapping['Twitter'])
    @editedBio.othersocialmedia = SurveyService.getValueOfMappedQuestion(person, QuestionMapping['OtherSocialMedia'])
    @editedBio.photourl = SurveyService.getValueOfMappedQuestion(person, QuestionMapping['Photo'])
    @editedBio.facebook = SurveyService.getValueOfMappedQuestion(person, QuestionMapping['Facebook'])
    render :layout => 'content'
  end
  
  def edit
    @editedBio = EditedBio.find(params[:id])
    
    if (@editedBio.website == nil)
      @editedBio.website = @editedBio.person.GetWebSite
    end
    
    if (@editedBio.twitterinfo == nil)
      @editedBio.twitterinfo = @editedBio.person.GetTwitterInfo
    end
    
    if (@editedBio.othersocialmedia == nil)
      @editedBio.othersocialmedia = @editedBio.person.GetOtherSocialMediaInfo
    end
    
    if (@editedBio.photourl == nil)
      @editedBio.photourl = @editedBio.person.GetPhotoUrl
    end
      if (@editedBio.facebook == nil)
      @editedBio.facebook = @editedBio.person.GetFacebookInfo
    end
    
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
  
  def exportbiolist
    exportSelect = params[:selectExportBioList][:export_select]
    accepted = AcceptanceStatus.find_by_name("Accepted")        
    invitestatus = InviteStatus.find_by_name("Invited")
    
    if (exportSelect == 'true')
       updatedValueYear = params[:selectExportBioList]['updated_at(1i)']
       updatedValueMon = params[:selectExportBioList]['updated_at(2i)']
       updatedValueDay = params[:selectExportBioList]['updated_at(3i)']
       updatedValueHour = params[:selectExportBioList]['updated_at(4i)']
       updatedValueMinute = params[:selectExportBioList]['updated_at(5i)']
       updatedValueSecond = params[:selectExportBioList]['updated_at(5i)']    
       updateValue = Time.zone.local(updatedValueYear,updatedValueMon,updatedValueDay,updatedValueHour,updatedValueMinute,updatedValueSecond)
    
       @editedBios = EditedBio.find :all, :joins => :person, :conditions => ['people.acceptance_status_id = ? and people.invitestatus_id = ? and edited_bios.updated_at > ?', accepted.id, invitestatus.id, updateValue], :order => 'last_name, first_name'
    else
       @editedBios = EditedBio.find :all, :joins => :person, :conditions => ['people.acceptance_status_id = ? and people.invitestatus_id = ?', accepted.id, invitestatus.id], :order => 'last_name, first_name'
    end
    render :layout => 'content'
  end
  
  def selectExportBioList
    
  end
end

