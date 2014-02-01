class MailConfigsController < PlannerController
  
  #
  #
  #
  def index
    # TODO - when we have multi-tenant base this on the current convention...
    mail_config = MailConfig.find :first
    
    render json: mail_config.to_json, :content_type => 'application/json'
  end

  def show
    mail_config = MailConfig.find(params[:id])

    render json: mail_config.to_json, :content_type => 'application/json'
  end

  def create
    mail_config = MailConfig.find(params[:id])
    mail_config.save!

    render json: mail_config.to_json, :content_type => 'application/json'
  end

  def update
    mail_config = MailConfig.find(params[:id])
    mail_config.update_attributes(params[:mail_config])

    render json: mail_config.to_json, :content_type => 'application/json'
  end

  def destroy
    mail_config = MailConfig.find(params[:id])
    mail_config.destroy

    render status: :ok, text: {}.to_json
  end
end
