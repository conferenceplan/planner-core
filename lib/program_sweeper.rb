class ProgramSweeper < ActionController::Caching::Sweeper
  
  observe PublicationDate
  
  def after_create(r)
      Rails.cache.clear # make sure that the mem cache is flushed
  end
  
end