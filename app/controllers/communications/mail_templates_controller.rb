class Communications::MailTemplatesController < PlannerController
  def index
    @mail_templates = MailTemplate.all
  end

  def show
    @mail_template = MailTemplate.find(params[:id])
  end

  def create
    @mail_template = MailTemplate.new(params[:mail_template])
    @mail_template.save!
  end

  def update
    @mail_template = MailTemplate.find(params[:id])

    @mail_template.update_attributes(params[:mail_template])
  end

  def destroy
    mail_template = MailTemplate.find(params[:id])
    
    begin
      mail_template.destroy
      render status: :ok, text: {}.to_json
    rescue => ex
      render status: :bad_request, text: ex.message
    end
    
  end
end
