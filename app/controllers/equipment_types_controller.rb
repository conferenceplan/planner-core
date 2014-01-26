class EquipmentTypesController < PlannerController
  
  #
  #
  #
  def index
    equipment_types = EquipmentType.find :all
    
    render json: equipment_types.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def show
    equipment_type = EquipmentType.find params[:id]
    
    render json: equipment_type.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def create
    equipment_type = EquipmentType.new params[:equipment_type]
    equipment_type.save!
    
    render json: equipment_type.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def update
    equipment_type = EquipmentType.find params[:id]
    equipment_type.update_attributes params[:equipment_type]
    
    render json: equipment_type.to_json, :content_type => 'application/json'
  end
  
  #
  #
  #
  def destroy
    EquipmentType.find(params[:id]).destroy
    render status: :ok, text: {}.to_json
  end

end
