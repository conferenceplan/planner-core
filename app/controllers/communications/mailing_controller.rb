class Communications::MailingController < PlannerController
  
  def index
    @mailings = Mailing.all
  end
  
  # def list
    # # TODO - get a pageable list ???
    # @mailings = Mailing.all
  # end

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
