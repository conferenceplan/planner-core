class EquipmentTypesController < PlannerController
   def index
      @equipment_types = EquipmentType.find :all
   end

   def list
     @equipment_types = EquipmentType.find :all
     render :action => :list, :layout => "plain"
   end

   def show
      @equipment_type = EquipmentType.find params[:id]
   end
   def new
      @equipment_type = EquipmentType.new
   end
   def create
      @equipment_type = EquipmentType.new params[:equipment_type]
      if @equipment_type.save
         redirect_to :action => 'index'
      else
         render :action => 'new'
      end
   end
   def edit
      @equipment_type = EquipmentType.find params[:id]
   end
   def update
      @equipment_type = EquipmentType.find params[:id]
      if @equipment_type.update_attributes params[:equipment_type]
         redirect_to :action => 'index'
      else
         render :action => 'edit'
      end
   end
   def destroy
      EquipmentType.find(params[:id]).destroy
      redirect_to :action => 'index'
   end
end
