#
#
#
class PlannerController < ApplicationController
  before_filter :require_user
  filter_access_to :all # Only allow roles that have manage permission to use any of the methods in this controller

  def createWhereClause(filters, integerFieldsSkipIfEmpty = [], integerFields = [])
    clause = nil
    fields = Array::new
    j = ActiveSupport::JSON
    
    if (filters)
      queryParams = j.decode(filters)
      if (queryParams)
        clausestr = ""
        queryParams["rules"].each do |subclause|
          # these are the select type filters - position 0 is the empty position and means it is not selected,
          # so we are not filtering on that item
          next if (integerFieldsSkipIfEmpty.include?(subclause['field']) && subclause['data'] == '0')        
          
          if clausestr.length > 0 
            clausestr << ' ' + queryParams["groupOp"] + ' '
          end
          
          # integer items (integers or select id's) need to be handled differently in the query
          isInteger = integerFields.include?(subclause['field'])
          if subclause["op"] == 'ne'
            clausestr << subclause['field'] + lambda { return isInteger ? ' != ?' : ' not like ?' }.call
          else
            clausestr << subclause['field'] + lambda { return isInteger ? ' = ?' : ' like ?' }.call
          end
          fields << lambda { return isInteger ? subclause['data'].to_i : subclause['data'] + '%' }.call
        end
        clause = [clausestr] | fields
      end
    end
    return clause
  end
  
  def addClause(clause, clausestr, field)
    if clause == nil || clause.empty?
      clause = [clausestr, field]
    else
      clause[0] += " AND " if !clause[0].strip().empty?
      clause[0] += " " + clausestr
      clause << field
    end
    
    return clause
  end
end
