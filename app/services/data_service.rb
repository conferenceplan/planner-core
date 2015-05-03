#
#
#
module DataService
  
  def self.genTagSql(context, tags)
    tagquery = ""
    if context
      if context.class == HashWithIndifferentAccess
        context.each do |key, ctx|
          # tagquery += ".tagged_with('" + tags[key].gsub(/'/, "\\\\'").gsub(/\(/, "\\(").gsub(/\)/, "\\)") + "', :on => '" + ctx + "', :any => true)"
          tagquery += ".tagged_with('" + tags[key].gsub(/'/, "\\\\'") + "', :on => '" + ctx + "', :any => true)"
        end
      else
        # tagquery += ".tagged_with('" + tags.gsub(/'/, "\\\\'").gsub(/\(/, "\\(").gsub(/\)/, "\\)") + "', :on => '" + context + "', :op => true)"
        tagquery += ".tagged_with('" + tags.gsub(/'/, "\\\\'") + "', :on => '" + context + "', :match_all => true)"
        #.gsub("&"){'\&'}
      end
    end
    
    tagquery
  end
  
  #
  #
  #
  def self.getFilterData(filters, key)
    j = ActiveSupport::JSON
    data = nil
    
    if (filters != nil && key != nil)
      queryParams = j.decode(filters)
      if (queryParams && queryParams["rules"].any?)
        queryParams["rules"].each do |subclause|
          if subclause['field'] == key
            isInteger = Integer(subclause['data']) rescue nil
            useData = isInteger ? Integer(subclause['data']) > 0 : true
            return subclause['data'] if useData && !subclause['data'].empty?
          end 
        end
      end
    end
    
    return data
  end
  
  #
  #
  #
  def self.createWhereClause(filters, integerFieldsSkipIfEmpty = [], integerFields = [], skipfields = [])
    clause = nil
    fields = Array::new
    j = ActiveSupport::JSON
    
    if (filters != nil)
      queryParams = j.decode(filters)
      if (queryParams && queryParams["rules"].any?)
        clausestr = ""
        queryParams["rules"].each do |subclause|
          # these are the select type filters - position 0 is the empty position and means it is not selected,
          # so we are not filtering on that item
          next if (integerFieldsSkipIfEmpty.include?(subclause['field']) && subclause['data'] == '0')        
          next if (skipfields.include? subclause['field'])
          
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
          elsif subclause["op"] == 'gt'
            clausestr << subclause['field'] + lambda { return isInteger ? ' = ?' : ' > ?' }.call
          elsif subclause["op"] == 'lt'
            clausestr << subclause['field'] + lambda { return isInteger ? ' = ?' : ' < ?' }.call
          else # also the eq, cn, bw
            clausestr << subclause['field'] + lambda { return isInteger ? ' = ?' : ' like ?' }.call
          end
           
          if subclause["op"] == 'nc' || subclause["op"] == 'cn'
             fields << lambda { return isInteger ? subclause['data'].to_i : '%' + subclause['data'] + '%' }.call
          else
             fields << lambda { return isInteger ? subclause['data'].to_i : subclause['data'] + '%' }.call
          end
        end
        clause = [clausestr].concat fields
      end
    end
    return clause
  end
  
  #
  #
  #
  def self.addClause(clause, clausestr, field = nil)
    if (clause == nil) || clause.empty?
      clause = [clausestr, field]
    else
      isEmpty = clause[0].strip().empty?
      clause[0] = " ( " + clause[0]
      clause[0] += ") AND ( " if ! isEmpty
      clause[0] += " " + clausestr
      clause[0] += " ) "  #if ! isEmpty
      if field
        clause << field
      end
    end
    
    return clause
  end
  
end
