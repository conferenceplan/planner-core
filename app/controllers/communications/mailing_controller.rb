class Communications::MailingController < PlannerController
  
  def index
    @mailings = Mailing.all
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
    rescue Exception
      render status: :bad_request, text: 'unable to add the people to the mailing list'
    end
  end
  
  def removePeople
    people = params[:people]
    mailingId = params[:mailing]
    
    begin
      PersonMailingAssignment.transaction do
        people.each do |pid|
          # find the mailing assignment
          mailingAssignment = PersonMailingAssignment.first conditions: { person_id: pid, mailing_id: mailingId }
          
          # and then delete it
          mailingAssignment.destroy
        end
      end
      render status: :ok, text: {}.to_json
    rescue Exception
      render status: :bad_request, text: 'unable to remove the people from the mailing list'
    end
  end
  
  def show
    @mailing = Mailing.find params[:id]
  end

  def create
    @mailing = Mailing.new params[:mailing]
    @mailing.save!
  end

  def update
    @mailing = Mailing.find params[:id]

    @mailing.update_attributes(params[:mailing])
  end

  def destroy
    mailing = Mailing.find params[:id]
    
    mailing.destroy
    render status: :ok, text: {}.to_json
  end
  
end
