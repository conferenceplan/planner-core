class Communications::MailTemplatesController < PlannerController
  # def list
    # # return a list of the mail templates
  # end

  def index
    @mail_templates = MailTemplate.all
  end

  def show
    @mail_template = MailTemplate.find(params[:id])
  end

  def create
    @mail_template = MailTemplate.new(params[:mail_template])
  end

  def update
    @mail_template = MailTemplate.find(params[:id])

    @mail_template.update_attributes(params[:mail_template])
  end

  def destroy
    @mail_template = MailTemplate.find(params[:id])
    @mail_template.destroy
  end
end
