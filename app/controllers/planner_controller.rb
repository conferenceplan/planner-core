#
#
#
class PlannerController < ApplicationController
  before_filter :require_user # All controllers that inherit from this will require an authenticated user
  filter_access_to :all # All controllers that inherit from this will be controlled by the access rules

  def permission_denied
    render '/errors/permission_error'
  end

private

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
          if subclause["op"] == 'ne' || subclause["op"] == 'nc' || subclause["op"] == 'bn'
            clausestr << subclause['field'] + lambda { return isInteger ? ' != ?' : ' not like ?' }.call
          elsif subclause["op"] == 'ge'
            clausestr << subclause['field'] + lambda { return isInteger ? ' = ?' : ' >= ?' }.call
          elsif subclause["op"] == 'le'
            clausestr << subclause['field'] + lambda { return isInteger ? ' = ?' : ' <= ?' }.call
          else # also the eq, cn, bw
            clausestr << subclause['field'] + lambda { return isInteger ? ' = ?' : ' like ?' }.call
          end
           
          if subclause["op"] == 'nc' || subclause["op"] == 'cn'
             fields << lambda { return isInteger ? subclause['data'].to_i : '%' + subclause['data'] + '%' }.call
          else
             fields << lambda { return isInteger ? subclause['data'].to_i : subclause['data'] + '%' }.call
          end
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
      isEmpty = clause[0].strip().empty?
      clause[0] = " ( " + clause[0]
      clause[0] += ") AND ( " if ! isEmpty
      clause[0] += " " + clausestr
      clause[0] += " ) "  if ! isEmpty
      clause << field
    end
    
    return clause
  end
end
