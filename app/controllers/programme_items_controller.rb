class ProgrammeItemsController < ApplicationController

  def index
    @programmeItems = ProgrammeItem.find :all
  end
  def show
    @programmeItem = ProgrammeItem.find(params[:id])
  end
  def create
    @programmeItem = ProgrammeItem.new(params[:programme_item])
    if (@programmeItem.save)
       redirect_to :action => 'show', :id => @programmeItem
    else
      render :action => 'new'
    end 
  end
  def new
    @programmeItem = ProgrammeItem.new
  end
  
  def edit
    @programmeItem = ProgrammeItem.find(params[:id])
  end
  
  def update
    @programmeItem = ProgrammeItem.find(params[:id])
    if @programmeItem.update_attributes(params[:programme_item])
      redirect_to :action => 'show', :id => @programmeItem
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @programmeItem = ProgrammeItem.find(params[:id])
    @programmeItem.destroy
    redirect_to :action => 'index'
  end
  
end
