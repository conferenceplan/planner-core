class Admin::MailingsController < PlannerController
  def index
  end

  def new
    # NOTE: we need a new method for the create to work...
  end

  def create
    mailing = Mailing.new()
    mailing.mailing_number = params[:mailing_number]
    mailing.mail_template_id = params[:mail_template_id]

    ActiveRecord::Base.include_root_in_json = false # hack for now

    if mailing.save
      render :json => mailing, :callback => params[:callback]
    else
      render :json => mailing, :callback => params[:callback] # TODO
    end
  end

  def edit
  end

  def update
    mailing = Mailing.find(params[:id])

    mailing.testrun = params[:testrun]
    mailing.scheduled = params[:scheduled]
    
    mailing.save!

    if mailing.scheduled
      mailingJob = MailingJob.new
      Delayed::Job.enqueue mailingJob
    end
    
    ActiveRecord::Base.include_root_in_json = false
    
    render :json => mailing, :callback => params[:callback]
    # TODO - handle error

  end

  def destroy
  end
  
  def list
    mailings = Mailing.find :all
    
    ActiveRecord::Base.include_root_in_json = false # hack for now

    render :json => mailings, :callback => params[:callback]
  end

  def listMailTemplates
    templates = MailTemplate.find :all #, :joins => :enumrecord, :conditions => {:mail_use_id => :enumrecord}

    ActiveRecord::Base.include_root_in_json = false # hack for now

    render :json => templates, :callback => params[:callback]
  end
  
  def previewEmail
    # For person for given mailing
    person = Person.find params[:person_id]
    mailing = Mailing.find params[:mailing_id]
    
    # mailer = SurveyMailer.new

    content = SurveyMailer.preview(person, mailing, {
            :person => person,
            :assignments => ProgramItemsService.findProgramItemsForPerson(person)
    }) 
    
    render :json => {:content => content}, :callback => params[:callback]
  end
  
end
