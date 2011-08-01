class ProgramSweeper < ActionController::Caching::Sweeper
  
  observe PublicationDate
  
  def after_create(r)
    expire_action(:controller => 'program', :action => :participants)
    expire_action(:controller => 'program', :action => :index)
  end
  
end