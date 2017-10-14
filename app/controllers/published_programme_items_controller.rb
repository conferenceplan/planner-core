class PublishedProgrammeItemsController < ResourceController
  
  # do the search
  def collection
    search = params[:search]
    
    if search
      super.includes(:translations).references(:translations).limit(20).where(["published_programme_item_translations.title like ?", '%' + search + '%']).where("parent_id is null").order('published_programme_item_translations.title asc')
    else
      super.includes(:translations).references(:translations).limit(20).where("parent_id is null").order('published_programme_item_translations.title asc')
    end
  end
  
end
