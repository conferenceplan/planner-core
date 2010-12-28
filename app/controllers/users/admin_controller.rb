class Users::AdminController < ApplicationController

  # TODO - refactor
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
    count = User.count :conditions => clause
    @nbr_pages = (count / rows.to_i).floor + 1
    
    off = (@page.to_i - 1) * rows.to_i
    @users = User.find :all, :offset => off, :limit => rows, :order => idx + " " + order, :conditions => clause
   
    respond_to do |format|
      format.xml
    end
  end

  def destroy
    user = User.find(params[:id])
    
    user.destroy
    render :layout => 'success'
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    
    if (@user.save)
       redirect_to :action => 'index'
    else
      # TODO - report an error
      render :content
    end 
  end

  def update
    @user = User.find(params[:id])
    
    if @user.update_attributes(params[:user])
      redirect_to :action => 'show',:id => @user
    else
      render :action => 'edit', :layout => 'content'
    end
  end

  def index
  end

  def show
  end

end
