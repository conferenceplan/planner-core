class Mobile::ThemeController < PlannerController
  def show
    theme = MobileTheme.find(params[:id])
    
    render json: theme.to_json, :content_type => 'application/json'
  end

  def create
    begin
      MobileTheme.transaction do
        theme = MobileTheme.new(params[:theme])
        theme.save!

        render json: theme.to_json, :content_type => 'application/json'
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  def update
    begin
      MobileTheme.transaction do
        theme = MobileTheme.find(params[:id])
        theme.update_attributes(params[:theme])
        render json: theme.to_json, :content_type => 'application/json'
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  def destroy
    begin
      MobileTheme.transaction do
        theme = MobileTheme.find(params[:id])
        theme.destroy
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end

    render status: :ok, text: {}.to_json
  end

  def index
    # if not found then create one
    if MobileTheme.count == 0
      theme = MobileTheme.new
      theme.save!
    end
    
    themes = MobileTheme.find :all, :order => 'name'
    
    render json: themes.to_json, :content_type => 'application/json'
  end

end
