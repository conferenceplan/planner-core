class EquipmentTypesController < PlannerController
  
  #
  #
  #
  def index
    equipment_types = EquipmentType.all
    
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
    # if the equipment is being used by other program items then do not allow the delete
    candidate = EquipmentType.find(params[:id])
    
    if candidate.programme_items.size > 0
      render status: :bad_request, text: 'Can not delete equipment associated with program items'
    else  
      EquipmentType.find(params[:id]).destroy
      render status: :ok, text: {}.to_json
    end
  end

end
