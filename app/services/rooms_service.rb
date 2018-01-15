#
#
#
module RoomsService
  
  #
  #
  #
  def self.findPublishedRooms
    PublishedRoom.all.order('name')
  end
  
  #
  #
  #
  def self.countRooms(filters = nil, venue_id = nil, page_to = nil)
    args = genArgsForSql(filters, venue_id, page_to)

    Room.where(where_clause(filters, venue_id)).
        joins(join_clause).count
  end
  
  #
  #
  #
  def self.findRooms(rows=15, page=1, index='sort_order', sort_order='asc', filters = nil, venue_id = nil)
    args = genArgsForSql(filters, venue_id)

    offset = (page - 1) * rows.to_i
    offset = 0 if offset < 0
    
    Room.where(where_clause(filters, venue_id)).
        joins(join_clause).
        offset(offset).
        limit(rows).
        order(index + " " + sort_order)
  end
  
  def self.where_clause(filters, venue_id= nil, page_to = nil)
    clause = DataService.createWhereClause(filters)
    
    # clause = DataService.addClause( clause, 'rooms.name <= ?', page_to) if page_to
    clause = DataService.addClause( clause, 'rooms.venue_id = ?', venue_id) if venue_id
    
    clause
  end
  
  def self.join_clause(filters, venue_id= nil, page_to = nil)
    joinSQL  = "LEFT JOIN venues ON venues.id=rooms.venue_id "
    joinSQL += "LEFT JOIN room_setups ON room_setups.id=rooms.setup_id "
    joinSQL += "LEFT JOIN setup_types ON setup_types.id=room_setups.setup_type_id"

    joinSQL
  end
  
end
