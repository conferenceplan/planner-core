require 'mailing_job'

class Communications::MailingController < PlannerController
  
  def index
    @mailings = Mailing.joins(:mail_template).all
  end
  
  def listWithBlank
    @mailings = Mailing.all.order("mailings.mailing_number asc")
    render :layout => 'plain'
  end

  # Add person
  def addPeople
    people = params[:people]
    mailingId = params[:mailing]
    
    begin
      PersonMailingAssignment.transaction do
        people.each do |pid|
          mailingAssignment = PersonMailingAssignment.new
        
          mailingAssignment.person_id = pid
          mailingAssignment.mailing_id = mailingId
          
          mailingAssignment.save!
        end
      end
      render status: :ok, text: {}.to_json
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end
  
  def removePeople
    people = params[:people]
    mailingId = params[:mailing]
    
    begin
      PersonMailingAssignment.transaction do
        people.each do |pid|
          # find the mailing assignment
          mailingAssignment = PersonMailingAssignment.where({ person_id: pid, mailing_id: mailingId }).first
          
          # and then delete it
          mailingAssignment.destroy
        end
      end
      render status: :ok, text: {}.to_json
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  def previewEmail
    # For person for given mailing
    person = Person.find params[:person_id]
    mailing = Mailing.find params[:mailing]
    
    content = MailService.preview(person, mailing, request.protocol + request.host_with_port + baseUri_no_lang)
    
    render :json => {:content => content}
  end
  
  def show
    @mailing = Mailing.find params[:id]
  end

  def create
    begin
      @mailing = Mailing.new params[:mailing]
      @mailing.save!
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  def update
    @mailing = Mailing.find params[:id]

    begin
      @mailing.update_attributes(params[:mailing])
      @mailing.save!
      
      if @mailing.scheduled
        mailingJob = MailingJob.new
        mailingJob.mailing_id = @mailing.id
        mailingJob.base_url = request.protocol + request.host_with_port + baseUri_no_lang
        Delayed::Job.enqueue mailingJob
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  def destroy
    mailing = Mailing.find params[:id]
    
    if mailing.scheduled
      render :bad_request, text: "Can not remove a mailing that is scheduled"
    else  
      mailing.destroy
      render status: :ok, text: {}.to_json
    end
  end
  
end
