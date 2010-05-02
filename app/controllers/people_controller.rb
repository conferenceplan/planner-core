class PeopleController < ApplicationController
  
#  layout 'content'
  
  def destroy
    @person = Person.find(params[:id])
    @person.destroy
    redirect_to :action => 'index'
  end

  def show
    @person = Person.find(params[:id])
  end

  def edit
    @person = Person.find(params[:id])
  end

  def new
    @participant = Person.new
  end

  def create
    @participant = Person.new(params[:person])

    if (@participant.save)
       redirect_to :action => 'show', :id => @participant
    else
      render :action => 'new'
    end 
  end

  def update
    @person = Person.find(params[:id])
#    if @event.update_attributes(params[:event])
#      redirect_to :action => 'show', :id => @event
#    else
#      render :action => 'edit'
#    end
  end

  #
  # All the index method does is provide formatting, the actual
  # work for the listing of people is done by the list method
  #
  def index
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  #
  def list
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]
    
    # First we need to know how many records there are in the database

    # Then we get the actual data we want from the DB
    count = Person.count
    @nbr_pages = (count / rows.to_i).floor + 1
    
    off = (@page.to_i - 1) * rows.to_i
    @people = Person.find :all, :offset => off, :limit => rows, :order => idx + " " + order
   
    # We return the list of people as an XML structure which the 'table' can use.
    # TODO: would it be more efficient to use JSON instead?
    respond_to do |format|
      format.xml
    end
  end

end
