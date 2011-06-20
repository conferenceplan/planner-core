class EquipmentNeedsController < ApplicationController
  
  def new
    if (params[:programme_item_id])
      @urlstr = '/programme_items/' + params[:programme_item_id] + '/equipment_needs'
    else
      @urlstr = '/equipmentNeeds'
    end
    @equipmentNeed = EquipmentNeed.new 

    render :layout => 'content'
  end

  def edit
    @equipmentNeed = EquipmentNeed.find(params[:id])
    render :layout => 'content'
  end

  def update
    @equipmentNeed = EquipmentNeed.find(params[:id])

    if @equipmentNeed.update_attributes(params[:equipment_need])
      redirect_to :action => 'show', :id => @equipmentNeed
    else
      render :action => 'edit'
    end
  end

  def create
    if (params[:programme_item_id])
      @programmeItem = ProgrammeItem.find(params[:programme_item_id])
      @equipmentNeed = EquipmentNeed.new(:programme_item_id => params[:programme_item_id],
                                 :equipment_type_id => params[:equipment_need][:equipment_type_id])
      @programmeItem.equipment_needs << @equipmentNeed
    else
      # TODO - we may not want to create an address without having a person to assigned it to it?
      @equipmentNeed = EquipmentNeed.new(params[:equipment_need]);
    end
    
    if (@programmeItem.save)
#      We want to go back to?
       redirect_to :action => 'show', :id => @equipmentNeed
    else
      render :action => 'new'
    end 
  end

  def show
    @equipmentNeed = EquipmentNeed.find(params[:id])

    render :layout => 'content'
  end

  def destroy
    # TODO - make sure that this cleans up the relationships in the Address table
    @equipmentNeed = EquipmentNeed.find(params[:id])
    @equipmentNeed.destroy
    render :layout => 'success'
  end

  def index
#    person = Person.find(params[:person_id])
#    
#    @emailAddresses = person.email_addresses
      
    programme_item = ProgrammeItem.find(params[:programme_item_id])
    @equipmentNeeds = programme_item.equipment_needs;
    @urlstr = '/programme_items/'+ params[:programme_item_id]  + '/equipment_needs/new'
    
    render :layout => 'content'
  end
  
end
