class PeopleController < ApplicationController
  def destroy
    @person = Person.find(params[:id])
    @person.destroy
    redirect_to :action => 'index' # change
  end

  def edit
    @person = Person.find(params[:id])
  end

#    TODO - change so that we do not return a full list, need to scroll through
  def index
    @people = Person.find :all
  end

  def new
    @participant = Person.new
  end

  def create
    @person = Person.new(params[:person])

    if (@person.save)
       redirect_to :action => 'show', :id => @person
    else
      render :action => 'new'
    end 
  end

  def show
    @person = Person.find(params[:id])
  end

  def update
    @person = Person.find(params[:id])
#    if @event.update_attributes(params[:event])
#      redirect_to :action => 'show', :id => @event
#    else
#      render :action => 'edit'
#    end
  end

end
