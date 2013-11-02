class EquipmentNeedsController < PlannerController
  
  def update
    @equipment = EquipmentNeed.find(params[:id])

    @equipment.update_attributes(params[:equipment_need])
    
    # render json: equipmentNeed.to_json, :content_type => 'application/json'
  end

  def create
    if (params[:programme_item_id])
      programmeItem = ProgrammeItem.find(params[:programme_item_id])
      equipmentNeed = EquipmentNeed.new(:programme_item_id => params[:programme_item_id],
                                        :equipment_type_id => params[:equipment_need][:equipment_type_id])
      programmeItem.equipment_needs << equipmentNeed
      programmeItem.save!
    else
      # TODO - is this needed i.e. equipment needed without a program item does not make sense?
      equipmentNeed = EquipmentNeed.new(params[:equipment_need]);
    end
    
    render json: equipmentNeed.to_json, :content_type => 'application/json'
  end

  def show
    equipmentNeed = EquipmentNeed.find(params[:id])

    render json: equipmentNeed.to_json, :content_type => 'application/json'
  end

  def destroy
    equipmentNeed = EquipmentNeed.find(params[:id])
    equipmentNeed.destroy
    render status: :ok, text: {}.to_json
  end

  def index
    programme_item = ProgrammeItem.find(params[:programme_item_id])
    @equipmentNeeds = programme_item.equipment_needs;
    
    # render json: equipmentNeeds.to_json, :content_type => 'application/json'
  end
  
end
