class Panels::ItemMgmtController < PlannerController
  layout "panel"
  
  def index
    @prog_item = params.has_key?(:prog_item) ? params[:prog_item] : nil
  end
end
