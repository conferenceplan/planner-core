class PublishedProgrammeItemsController < ResourceController
  
  # do the search
  def collection
    search = params[:search]
    
    if search
      super.limit(20).where(["title like ?", '%' + search + '%']).where("parent_id is null").order('title asc')
    else
      super.limit(20).where("parent_id is null").order('title asc')
    end
  end
  
end
