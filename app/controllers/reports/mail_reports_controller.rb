class Reports::MailReportsController < PlannerController
  
  def index
    @person = @mailing = nil
    
    @person_id = params[:person_id]
    @mailing_id = params[:mailing_id]
    
    @person = Person.find(@person_id) if @person_id
    @mailing = Mailing.find(@mailing_id) if @mailing_id
  end

end
