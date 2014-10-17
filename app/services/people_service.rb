#
#
#
module PeopleService
  
  #
  # Get people who have been invited and have accepted
  # along with their Bios
  #
  def self.findConfirmedPeople(peopleIds = nil, tag = nil)
    whereClause = {'person_con_states.acceptance_status_id' => AcceptanceStatus['Accepted'], 'person_con_states.invitestatus_id' => InviteStatus['Invited'] }
    whereClause[:id] = peopleIds if peopleIds
    
    if (tag)
      Person.tagged_with(tag, :on => 'PrimaryArea', :op => true).where(whereClause).includes([:pseudonym, :bio_image, :edited_bio]).
              joins(:person_con_state).
              order("people.last_name")
    else  
      Person.where(whereClause).includes([:pseudonym, :bio_image, :edited_bio]).
              joins(:person_con_state).
              order("people.last_name")
    end
  end
  
  #
  #
  #
  def self.findAssignedParticipants
    
    cndStr = 'programme_items.print = true'

    conditions = [cndStr] #, [AcceptanceStatus['Accepted'].id, AcceptanceStatus['Probable'].id]]

    # TODO - should this be from the published items rather than the pre-published?
    # TODO - need to test that programme item assignments actually exist
    Person.all :conditions => conditions, 
              :joins => { :programmeItemAssignments => {} },
              :include => {:pseudonym => {}, :programmeItemAssignments => {:programmeItem => {}} },
              :order => "people.last_name"

  end
  
  #
  #
  #
  def self.countPeople(filters = nil, extraClause = nil, onlySurveyRespondents = false, nameSearch=nil, context=nil, tags = nil, page_to = nil, mailing_id=nil, op=nil, scheduled=false, includeMailings=false)
    args = genArgsForSql(nameSearch, mailing_id, op, scheduled, filters, extraClause, onlySurveyRespondents, page_to, includeMailings)
    tagquery = DataService.genTagSql(context, tags)
    args.merge! :include => [:pseudonym, :email_addresses, :invitation_category]
    
    if tagquery.empty?
      Person.count args
    else
      eval "Person#{tagquery}.uniq.count( :all, " + args.inspect + ")"
    end
  end
  
  #
  #
  #
  def self.findPeople(rows=15, page=1, index='last_name', sort_order='asc', filters = nil, extraClause = nil, onlySurveyRespondents = false, nameSearch=nil, context=nil, tags = nil, mailing_id=nil, op=nil, scheduled=false, includeMailings=false)
    args = genArgsForSql(nameSearch, mailing_id, op, scheduled, filters, extraClause, onlySurveyRespondents, nil, includeMailings)
    tagquery = DataService.genTagSql(context, tags)
    
    offset = (page - 1) * rows.to_i
    offset = 0 if offset < 0
    args.merge!(:offset => offset, :limit => rows)
    if index
      args.merge!(:order => index + " " + sort_order)
    end
    
    args.merge! :include => [:pseudonym, :email_addresses, :invitation_category]
    
    if tagquery.empty?
      people = Person.includes(:pseudonym).find :all, args
    else
      people = eval "Person#{tagquery}.uniq.includes(:pseudonym).find :all, " + args.inspect
    end
  end
  
  private
  
  #
  #
  #
  def self.genArgsForSql(nameSearch, mailing_id, op, scheduled, filters, extraClause, onlySurveyRespondents, page_to = nil, includeMailings=false)
    clause = DataService.createWhereClause(filters, 
          ['person_con_states.invitestatus_id', 'invitation_category_id', 'person_con_states.acceptance_status_id', 'mailing_id'],
          ['person_con_states.invitestatus_id', 'invitation_category_id', 'person_con_states.acceptance_status_id', 'mailing_id'], ['people.last_name'])
    
    # add the name search for last of first etc
    if nameSearch #&& ! nameSearch.empty?
      # get the last name from the filters and use that in the clause
      st = DataService.getFilterData( filters, 'people.last_name' )
      if (st)
        terms = st.split # Get all the terms seperated by space
        str = ""
        terms.each do |x|
          str += " AND " if str.length > 0
          str += '(people.last_name like ? OR pseudonyms.last_name like ? OR people.first_name like ? OR pseudonyms.first_name like ? OR people.suffix like ? OR pseudonyms.suffix like ?)'
        end
        clause = DataService.addClause(clause,str)
        terms.each do |x|
          clause << '%' + x + '%'
          clause << '%' + x + '%'
          clause << '%' + x + '%'
          clause << '%' + x + '%'
          clause << '%' + x + '%'
          clause << '%' + x + '%'
        end
      end
    end
    
    if extraClause
      if (extraClause['value'].include? ',')
        vals  = extraClause['value'].split(',')
        clause = DataService.addClause( clause, extraClause['param'].to_s + ' in (?)', vals)
      else
        clause = DataService.addClause( clause, extraClause['param'].to_s + ' = ?', extraClause['value'].to_s)
      end
    end

    # Find people that do not have the specified mailing id
    # TODO - need the not in as well
    mailingQuery = 'people.id '
    mailingQuery += op if op
    mailingQuery +=  ' in (select person_id from person_mailing_assignments where mailing_id = ?)'
    clause = DataService.addClause( clause, mailingQuery, mailing_id) if mailing_id && ! mailing_id.empty?
    
    clause = DataService.addClause( clause, 'people.last_name <= ?', page_to) if page_to
    
    # Then we want to filter for scehduled people
    # select distinct person_id from programme_item_assignments;
    clause = DataService.addClause( clause, 'people.id in (select distinct person_id from room_item_assignments ra join programme_item_assignments pa on pa.programme_item_id = ra.programme_item_id)', nil) if scheduled

    # if the where clause contains pseudonyms. then we need to add the join
    args = { :conditions => clause }

    if args[:joins]
      args[:joins] += ' LEFT OUTER JOIN person_con_states on person_con_states.person_id = people.id'
    else  
      args.merge!( :joins => 'LEFT OUTER JOIN person_con_states on person_con_states.person_id = people.id' )
    end

    if includeMailings && clause && (clause[0].include? "mailing_id")
      if args[:joins]
        args[:joins] += ' LEFT JOIN person_mailing_assignments on people.id = person_mailing_assignments.person_id'
      else  
        args.merge!( :joins => 'LEFT JOIN person_mailing_assignments on people.id = person_mailing_assignments.person_id' )
      end
    end
    
    if onlySurveyRespondents
      if args[:joins]
        args[:joins] += ' JOIN survey_respondents ON people.id = survey_respondents.person_id'
      else  
        args.merge!( :joins => 'JOIN survey_respondents ON people.id = survey_respondents.person_id' )
      end
    end

    args
  end
  
end
