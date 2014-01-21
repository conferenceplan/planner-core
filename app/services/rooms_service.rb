#
#
#
module RoomsService
  
  #
  #
  #
  def self.findPublishedRooms
    PublishedRoom.find :all, :order => 'name'
  end
  
  #
  #
  #
  def self.countRooms(filters = nil, venue_id = nil, page_to = nil)
    args = genArgsForSql(filters, venue_id, page_to)

    Room.count args
  end
  
  #
  #
  #
  def self.findRooms(rows=15, page=1, index='name', sort_order='asc', filters = nil, venue_id = nil)
    args = genArgsForSql(filters, venue_id)

    offset = (page - 1) * rows.to_i
    
    args.merge!(:offset => offset, :limit => rows)
    if index
      args.merge!(:order => index + " " + sort_order)
    end
    
    Room.find :all, args
  end
  
  #
  #
  #
  def self.genArgsForSql(filters, venue_id= nil, page_to = nil)
    clause = DataService.createWhereClause(filters)
    
    clause = DataService.addClause( clause, 'rooms.name <= ?', page_to) if page_to
    clause = DataService.addClause( clause, 'rooms.venue_id = ?', venue_id) if venue_id
    
    args = { :conditions => clause }
    
    joinSQL  = "LEFT JOIN venues ON venues.id=rooms.venue_id "
    joinSQL += "LEFT JOIN room_setups ON room_setups.id=rooms.setup_id "
    joinSQL += "LEFT JOIN setup_types ON setup_types.id=room_setups.setup_type_id"
    
    args.merge!(:joins => joinSQL)
    
    args
  end
  
end
