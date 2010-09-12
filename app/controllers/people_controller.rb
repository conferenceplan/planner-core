class PeopleController < ApplicationController
  require 'csv'
  before_filter :require_user

  def destroy
    @person = Person.find(params[:id])
    
    # Get the addresses and if they are not reference by other people the get rid of them...
    @postalAddresses = @person.postal_addresses
    
    if (@postalAddresses)
      @postalAddresses.each do |address|
        @person.removeAddress(address)
      end
    end
    
    @person.destroy
    render :layout => 'success'
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
    
    if (@participant.save)
       redirect_to :action => 'show', :id => @participant
    else
      render :action => 'new'
    end 
  end

  def update
    @person = Person.find(params[:id])
    
    if @person.update_attributes(params[:person])
      redirect_to :action => 'show', :id => @person
    else
      render :action => 'edit'
    end
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
    j = ActiveSupport::JSON
    
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]
    clause = ""
    fields = Array::new
    
    if (params[:filters])
      queryParams = j.decode(params[:filters])
      if (queryParams)
        clausestr = ""
        queryParams["rules"].each do |subclause|
          if clausestr.length > 0 
            clausestr << ' ' + queryParams["groupOp"] + ' '
          end
          if subclause["op"] == 'ne'
            clausestr << subclause['field'] + ' not like ?'
          else
            clausestr << subclause['field'] + ' like ?'
          end
          fields << subclause['data'] + '%'
          logger.info fields
        end
        clause = [clausestr] | fields
      end
    end
    
    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB
    count = Person.count :conditions => clause
    @nbr_pages = (count / rows.to_i).floor + 1
    
    off = (@page.to_i - 1) * rows.to_i
    @people = Person.find :all, :offset => off, :limit => rows,
      :order => idx + " " + order, :conditions => clause
   
    # We return the list of people as an XML structure which the 'table' can us
    # TODO: would it be more efficient to use JSON instead?
    respond_to do |format|
      format.xml
    end
  end
  
  def import
    
  end
  
  def doimport
     @parsed_file=CSV::Reader.parse(params[:dump][:file])
     n=0
     @parsed_file.each  do |row|
        c=Person.new
    
        c.first_name=row[0]
        c.last_name=row[1]
        if c.save
           n=n+1
           GC.start if n%50==0
        end
        flash.now[:message]="CSV Import Successful,  #{n} new
                                records added to data base"
      end
      redirect_to :action => 'index'
    end
end