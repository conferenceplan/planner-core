class FormatsController < ResourceController
  
  def list  
    # Get all the formats in the database
    @formats = Format.find :all, :order => 'position asc'
    render :layout => 'plain'
  end
  
  def listwithblank
    # Get all the formats in the database
    @formats = Format.find :all , :order => 'position asc'
    render :layout => 'content'
  end

  # make sure that the collection is ordered by the position
  def collection
    super.order(:position)
  end

end
