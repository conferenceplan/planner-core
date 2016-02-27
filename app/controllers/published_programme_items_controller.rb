class PublishedProgrammeItemsController < ResourceController
  
  # do the search
  def collection
    search = params[:search]
    
    if search
      super.limit(20).where(["title like ?", '%' + search + '%']).order('title asc')
    else
      super.limit(20).order('title asc')
    end
  end
  
end
