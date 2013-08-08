#
#
#
module PeopleService
  
  #
  #
  #
  def self.countPeople(filters = nil, extraClause = nil, onlySurveyRespondents = false, nameSearch=nil, mailing_id=nil, scheduled=false, context=nil, tags = nil)
    args = genArgsForSql(nameSearch, mailing_id, scheduled, filters, extraClause, onlySurveyRespondents)
    tagquery = genTagSql(context, tags)
    
    if tagquery.empty?
      Person.count args
    else
      eval "Person#{tagquery}.count :all, " + args.inspect
    end
  end
  
  #
  #
  #
  def self.findPeople(rows=15, page=1, index='last_name', sort_order='asc', filters = nil, extraClause = nil, onlySurveyRespondents = false, nameSearch=nil, mailing_id=nil, scheduled=false,  context=nil, tags = nil)
    args = genArgsForSql(nameSearch, mailing_id, scheduled, filters, extraClause, onlySurveyRespondents)
    tagquery = genTagSql(context, tags)
    
    offset = (page - 1) * rows.to_i
    args.merge!(:offset => offset, :limit => rows)
    if index
      args.merge!(:order => index + " " + sort_order)
    end
    
    if tagquery.empty?
      people = Person.find :all, args
    else
      people = eval "Person#{tagquery}.find :all, " + args.inspect
    end
  end
  
  private
  
  #
  #
  #
  def self.genTagSql(context, tags)
    tagquery = ""
    if context
      if context.class == HashWithIndifferentAccess
        context.each do |key, ctx|
          tagquery += ".tagged_with('" + tags[key].gsub(/'/, "\\\\'").gsub(/\(/, "\\\\(").gsub(/\)/, "\\\\)") + "', :on => '" + ctx + "', :any => true)"
        end
      else
        tagquery += ".tagged_with('" + tags.gsub(/'/, "\\\\'").gsub(/\(/, "\\\\(").gsub(/\)/, "\\\\)") + "', :on => '" + context + "', :op => true)"
      end
    end
    
    tagquery
  end
  
  #
  #
  #
  def self.genArgsForSql(nameSearch, mailing_id, scheduled, filters, extraClause, onlySurveyRespondents)
    clause = DataService.createWhereClause(filters, 
          ['invitestatus_id', 'invitation_category_id', 'acceptance_status_id'],
          ['invitestatus_id', 'invitation_category_id', 'acceptance_status_id'])
    
    # add the name search for last of first etc
    if nameSearch && ! nameSearch.empty?
      clause = addClause(clause,'people.last_name like ? OR pseudonyms.last_name like ? OR people.first_name like ? OR pseudonyms.first_name like ?','%' + nameSearch + '%')
      clause << '%' + nameSearch + '%'
      clause << '%' + nameSearch + '%'
      clause << '%' + nameSearch + '%'
    end
    
    clause = DataService.addClause( clause, extraClause['param'].to_s + ' = ?', extraClause['value'].to_s) if extraClause

    clause = DataService.addClause( clause, 'people.id not in (select person_id from person_mailing_assignments where mailing_id = ?)', mailing_id) if mailing_id && ! mailing_id.empty?
    
    # Then we want to filter for scehduled people
    # select distinct person_id from programme_item_assignments;
    clause = DataService.addClause( clause, 'people.id in (select distinct person_id from room_item_assignments ra join programme_item_assignments pa on pa.programme_item_id = ra.programme_item_id)', nil) if scheduled

    # if the where clause contains pseudonyms. then we need to add the join
    args = { :conditions => clause }
    if nameSearch && ! nameSearch.empty?
      args.merge!( :joins => 'LEFT JOIN pseudonyms ON pseudonyms.person_id = people.id' )
    else
      args.merge!( :include => [:pseudonym] )
    end
    
    if onlySurveyRespondents
      args.merge!( :joins => 'JOIN survey_respondents ON people.id = survey_respondents.person_id' )
    end

    args
  end
  
end
