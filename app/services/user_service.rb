#
#
#
module UserService

  def self.countUsers(filters = nil, extraClause = nil, nameSearch = nil, page_to = nil, op = nil)
    where_clause = genArgsForSql(nameSearch, op, filters, extraClause, page_to)
    
    User.where(where_clause).count
  end
  
  def self.findUsers(rows=15, page=1, index = 'login', sort_order = 'asc', filters = nil, extraClause = nil, nameSearch = nil, page_to = nil, op = nil)
    where_clause = genArgsForSql(nameSearch, op, filters, extraClause, page_to)
    
    offset = (page - 1) * rows.to_i

    User.where(where_clause).offset(offset).limit(rows).order(index + " " + sort_order)
  end

protected

   def self.genArgsForSql(nameSearch, op, filters, extraClause, page_to)
    clause = DataService.createWhereClause(filters,[],[],['login'])

    if nameSearch #&& ! nameSearch.empty?
      # get the last name from the filters and use that in the clause
      st = DataService.getFilterData( filters, 'login' )
      if (st)
        clause = DataService.addClause(clause,'users.login like ? ','%' + st + '%')
      end
    end
    
    clause
  end
  
end
