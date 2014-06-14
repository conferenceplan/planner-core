class Users::AdminController < PlannerController  

  #
  #
  #
  respond_to :json
  def list
    rows = params[:rows] ? params[:rows] : 15
    @page = params[:page] ? params[:page].to_i : 1
    
    @currentId = params[:current_selection]

    page_to = params[:page_to]

    idx = (params[:sidx] && params[:sidx].length > 0) ? params[:sidx] : 'login'
    order = params[:sord] ? params[:sord] : 'asc'
    nameSearch = params[:namesearch]
    filters = params[:filters]
    extraClause = params[:extraClause]
    operation = params[:op]

    @count = UserService.countUsers filters, extraClause, nameSearch, nil, operation

    if page_to && !page_to.empty?
      gotoNum = UserService.countUsers filters, extraClause, nameSearch, page_to, operation
      if gotoNum
        @page = (gotoNum / rows.to_i).floor
        @page += 1 if gotoNum % rows.to_i > 0
      end
    end

    if rows.to_i > 0
      @nbr_pages = (@count / rows.to_i).floor
      @nbr_pages += 1 if @count % rows.to_i > 0
    else
      @nbr_pages = 1
    end
    
    # Then we get the actual data we want from the DB
    @users = UserService.findUsers rows, @page, idx, order, filters, extraClause, nameSearch, page_to, operation
  end

  #
  #
  #
  def destroy
    user = User.find(params[:id])
    
    user.destroy
    
    render status: :ok, text: {}.to_json
  end

  #
  #
  #
  def create
    begin
      User.transaction do
        # get the role and add it to the user
        @user = User.new #params[:user]
        @user.login = params[:login]
        @user.email = params[:email]
        @user.password = params[:password] if params[:password]
        @user.password_confirmation = params[:password_confirmation] if params[:password_confirmation]
        
        if (params[:roles])
          roleArray = params[:roles]
      
          roles = Role.find(roleArray.collect{|r| r[:id]})
          @user.roles << roles
        end
    
        @user.save!
      end
    rescue Exception => err  
      render status: :bad_request, text: err
    end
  end

  #
  #
  #
  def update
    @user = User.find params[:id]
    
    begin
      User.transaction do
        if (params[:roles])
          roleArray = params[:roles]
          
          @user.roles.clear
          
          Role.find(roleArray.collect{|r| r[:id]}).each do |role|
            assignment = RoleAssignment.new(:user => @user, :role => role)
            assignment.save!
          end
        end
        
        @user.email = params[:email]
        
        if (params[:password].length > 0) 
          @user.login = params[:login]
          @user.password = params[:password]
          @user.password_confirmation = params[:password_confirmation]
        end
        
        @user.save! 
      end
    rescue Exception => err  
      # IF there is a fail ten we can to catch the exception and report the problem
      render status: :bad_request, text: err
    end
  end

  #
  #
  #
  def index
    users = User.find :all
    render json: users.to_json, :content_type => 'application/json'
  end

  #
  #
  #
  def show
    @user = User.find params[:id]
  end

end
