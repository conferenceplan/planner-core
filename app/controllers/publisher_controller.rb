#
#
#
class PublisherController < PlannerController
  def index
  end

  def publish
    # Copy the selected program items into the published table
    
    # first we need to copy the programme item(s) - link them back via the publication table
    # link them back to the original item via the publication model
    # recreate the programme item assignments

    # second copy the room(s) and venue(s) (that have not already been copied)
    # link them back to the original
    # third copy the time slots    
  end

  def list
  end

private

  def copyProgrammeItems()
    
    # Get the items for publish
    ProgrammeItem srcItems = ProgrammeItem.all # TODO - change to get only the published (and changed)
    
    srcItems.each do |srcItem|
      newItem = copy(srcItem, Published::ProgrammeItem.new)
      publication = Published::Publication.new
      newItem.original = srcItem
      newItem.save
    end
    
  end

  # copy the attributes from the source that have an equivalent in the destination
  def copy(src, dest)
    src.attributes.each do |name, val|
      # but do not copy any of the variables needed for the optimistic locking, the id, etc
      if (dest.attributes.key? name) && (["lock_version", "created_at", "updated_at", "id"].index(name) == nil) 
        dest.write_attribute name , val
      end
    end
    
    return dest
  end

end
