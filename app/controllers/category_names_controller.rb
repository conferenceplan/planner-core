class CategoryNamesController < ResourceController

  def collection
    limit = params[:limit] ? params[:limit].to_i : nil
    offset = params[:offset] ? params[:offset].to_i : nil
    search = params[:search] ? params[:search] : nil

    sort_by = params[:sort] ? params[:sort] : 'name'
    sort_order = params[:order] ? params[:order] : 'asc'

    if search
      @total = super.where(["name like ?", '%' + search + '%' ]).count
      super.where(["name like ?", '%' + search + '%' ]).offset(offset).limit(limit).order(sort_by + ' ' + sort_order)
    else  
      @total = super.count
      super.offset(offset).limit(limit).order(sort_by + ' ' + sort_order)
    end
  end

end
