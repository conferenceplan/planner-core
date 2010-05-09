class PeopleController < ApplicationController
  
#  layout 'content'
  
  def destroy
    @person = Person.find(params[:id])
    @person.destroy
    redirect_to :action => 'index'
  end

  def show
    @person = Person.find(params[:id])

    render :layout => 'content'
  end

  def edit
    @person = Person.find(params[:id])
  end

  def new
    @participant = Person.new
  end

  def create
    @participant = Person.new(params[:person])

    # TODO - we want to see if the address exists already....? i.e. first do a find...
    # create the postal addrees
    postalAddress = PostalAddress.new(params[:postal_address])
    # Then create the association, assume that it is valid since we are just entering it :-)
    Address.create(:addressable => postalAddress, :person => @participant, :isvalid => true)

    # Now associate an email address with the person
    if (params[:email_address])
      emailAddress = EmailAddress.new(params[:email_address])
      Address.create(:addressable => emailAddress, :person => @participant, :isvalid => true)
    end

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
