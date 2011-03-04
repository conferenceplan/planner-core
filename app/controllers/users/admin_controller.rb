class Users::AdminController < PlannerController  
  def list
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]
    clause = ""
        
    if params['_search'] == "true"
       clause << ' ' + params["searchField"] + ' '
       if params["searchOper"] == "ne"
            clause << ' not like '
          else
            clause << ' like '
       end
       clause << ' \'' + params["searchString"] + '%\''
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
    # get the role and add it to the user
    roleArray = params[:userrole]

    role = Role.find(roleArray[:roles])
    @user.roles << role
    
    if (@user.save)
       redirect_to :action => 'index'
    else
      # TODO - report an error
      render :content
    end 
  end

  def update
    @user = User.find(params[:id])
    roleArray = params[:userrole]

    role = Role.find(roleArray[:roles])
    @user.roles.clear
    @user.roles << role
    
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
