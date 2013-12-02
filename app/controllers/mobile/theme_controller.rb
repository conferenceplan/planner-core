class Mobile::ThemeController < PlannerController
  def show
    @theme = MobileTheme.find(params[:id])
  end

  def create
    @theme = MobileTheme.new(params[:theme])
    @theme.save!
  end

  def update
    @theme = MobileTheme.find(params[:id])
    @theme.update_attributes(params[:theme])
  end

  def destroy
    theme = MobileTheme.find(params[:id])
    theme.destroy

    render status: :ok, text: {}.to_json
  end

  def index
    @theme = MobileTheme.find :first
    # if not found then create one
    if !@theme
      @theme = MobileTheme.new
      @theme.save!
    end
  end
end
