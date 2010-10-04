class PendingImportPeopleController < ApplicationController
  def index
    @pendingImportPeople = PendingImportPerson.find :all
  end
  def show
    @pendingImportPerson = PendingImportPerson.find(params[:id])
  end
  def create
    @pendingImportPerson = PendingImportPerson.new(params[:pending_import_person])
    if (@pendingImportPerson.save)
       redirect_to :action => 'show', :id => @pendingImportPerson
    else
      render :action => 'new'
    end 
  end
  def new
    @pendingImportPerson = PendingImportPerson.new
  end
  
  def edit
    @pendingImportPerson = PendingImportPerson.find(params[:id])
  end
  
  def update
    @pendingImportPerson = PendingImportPerson.find(params[:id])
    if @pendingImportPerson.update_attributes(params[:pending_import_person])
      redirect_to :action => 'show', :id => @pendingImportPerson
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @pendingImportPerson = PendingImportPerson.find(params[:id])
    @pendingImportPerson.destroy
    redirect_to :action => 'index'
  end
  
end
