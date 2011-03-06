class MonitorController < PlannerController

  def index
    # Get the all messages from the last 10 minutes that have not already been displayed to the user
    mid = session[:last_message_id] ? session[:last_message_id] : 0
    @messages = Message.all(:conditions => ["created_at > ? AND id > ?", 10.minutes.ago,mid])
    if @messages && @messages.length > 0
      session[:last_message_id] = @messages.last.id
      render :layout => 'content'
    else  
      render :nothing => true
    end
  end

end
