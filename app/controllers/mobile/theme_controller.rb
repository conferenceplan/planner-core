class Mobile::ThemeController < PlannerController
  def show
    theme = MobileTheme.find(params[:id])
    
    render json: theme.to_json, :content_type => 'application/json'
  end

  def create
    theme = MobileTheme.new(params[:theme])
    theme.save!
    
    render json: theme.to_json, :content_type => 'application/json'
  end

  def update
    theme = MobileTheme.find(params[:id])
    theme.update_attributes(params[:theme])
    
    render json: theme.to_json, :content_type => 'application/json'
  end

  def destroy
    theme = MobileTheme.find(params[:id])
    theme.destroy

    render status: :ok, text: {}.to_json
  end

  def index
    theme = MobileTheme.find :first
    # if not found then create one
    if !theme
      theme = MobileTheme.new
      theme.save!
    end
    
    render json: theme.to_json, :content_type => 'application/json'
  end
end
