#
#
#
module PeopleService
  
  #
  #
  #
  def self.merge_people(src_person, dest_person)
    # Take the details from the src_person and merge them into the dest_person
    # but do not change the dest person's name ....
    dest_person.language = src_person.language if dest_person.language.blank?
    dest_person.comments = src_person.comments if dest_person.comments.blank?
    dest_person.job_title = src_person.job_title if dest_person.job_title.blank?
    dest_person.save
    
    # postal address email address phone address
    src_person.addresses.each do |addr|
      addr.person = dest_person
      addr.save
    end
    
    if src_person.pseudonym && !dest_person.pseudonym
      pseudonym = src_person.pseudonym
      pseudonym.person = dest_person
      pseudonym.save
    end

    src_person.relationships do |relationship|
      relationship.person = dest_person
      relationship.save
    end
    
    # bio
    if src_person.edited_bio
      edited_bio = src_person.edited_bio
      if !dest_person.edited_bio
        edited_bio.person = dest_person
        edited_bio.save
      else # do a field by field copy where empty
        dest_bio = dest_person.edited_bio
        dest_bio.bio = edited_bio.bio if dest_bio.bio.blank?
        dest_bio.website = edited_bio.website if dest_bio.website.blank?
        dest_bio.twitterinfo = edited_bio.twitterinfo if dest_bio.twitterinfo.blank?
        dest_bio.othersocialmedia = edited_bio.othersocialmedia if dest_bio.othersocialmedia.blank?
        dest_bio.photourl = edited_bio.photourl if dest_bio.photourl.blank?
        dest_bio.facebook = edited_bio.facebook if dest_bio.facebook.blank?
        dest_bio.linkedin = edited_bio.linkedin if dest_bio.linkedin.blank?
        dest_bio.save
      end
    end

    if src_person.bio_image && !dest_person.bio_image
      bio_image = src_person.bio_image
      bio_image.person = dest_person
      bio_image.save
    end

    # links - not scoped
    src_person.linked.each do |link|
      link.linkedto_id = dest_person.id
      link.save
    end
    
    copy_single_relationships(src_person, dest_person)
    copy_many_relationships(src_person, dest_person)
  end
  
  # Need to do these across ALL conferences .... i.e. not scoped
  def self.copy_many_relationships(src_person, dest_person)
    [ProgrammeItemAssignment, PublishedProgrammeItemAssignment, PersonMailingAssignment, MailHistory, Exclusion].each do |claz|
      assignments = claz.where(person_id: src_person.id)
      assignments.each do |assignment|
        assignment.person = dest_person
        assignment.save
      end
    end
    
    taggings = ActsAsTaggableOn::Tagging.where({taggable_type: 'Person', taggable_id: src_person.id})
    taggings.each do |tagging|
      tagging.taggable_id = dest_person.id
      tagging.save
    end
  end

  def self.copy_single_relationships(src_person, dest_person)
    if src_person.registrationDetail
      if !dest_person.registrationDetail 
        reg_detail = src_person.registrationDetail
        reg_detail.person = dest_person
        reg_detail.save
      elsif !dest_person.registrationDetail.registered
        dest_person.registrationDetail.delete
        reg_detail = src_person.registrationDetail
        reg_detail.person = dest_person
        reg_detail.save
      end
    end

    if src_person.person_con_state
      if !dest_person.person_con_state
        person_con_state = src_person.person_con_state
        person_con_state.person = dest_person
        person_con_state.save
      else
        if src_person.person_con_state.acceptance_status
          dest_person.person_con_state.acceptance_status = src_person.person_con_state.acceptance_status if dest_person.person_con_state.acceptance_status.blank? || dest_person.person_con_state.acceptance_status == AcceptanceStatus["Unknown"]
        end
        if src_person.person_con_state.invitestatus
          dest_person.person_con_state.invitestatus = src_person.person_con_state.invitestatus if dest_person.person_con_state.invitestatus.blank? || dest_person.person_con_state.invitestatus == InviteStatus["Not Set"]
        end
        if src_person.person_con_state.invitation_category
          dest_person.person_con_state.invitation_category = src_person.person_con_state.invitation_category if dest_person.person_con_state.invitation_category.blank?
        end
        dest_person.person_con_state.save
      end
    end

    if !dest_person.available_date && src_person.available_date
      available_date = src_person.available_date
      available_date.person = dest_person
      available_date.save
    end

    if src_person.survey_respondent
      if !dest_person.survey_respondent
        survey_respondent = src_person.survey_respondent
        survey_respondent.person = dest_person
        survey_respondent.save
      else
        if !src_person.survey_respondent
          # move each of the surveys
          src_detail = src_person.survey_respondent.survey_respondent_detail
          dest_detail = dest_person.survey_respondent.survey_respondent_detail
  
          # go through each of the surveys
          surveys = Survey.all
          surveys.each do |survey|
            # if the dest already has a responses then do not copy ....
            if dest_detail.getResponses(survey.id).size == 0
              src_detail.getResponses(survey.id).each do |response|
                response.survey_respondent_detail = dest_detail
                response.save
              end
              src_detail.getHistories(survey.id).each do |history|
                history.survey_respondent_detail = dest_detail
                history.save
              end
            end
          end
        end
      end
    end

    if !dest_person.person_constraints && src_person.person_constraints
      person_constraints = src_person.person_constraints
      person_constraints.person = dest_person
      person_constraints.save
    end
  end
  
  #
  # Get people who have been invited and have accepted
  # along with their Bios
  #
  def self.findConfirmedPeople(peopleIds = nil, tag = nil)
    whereClause = {'person_con_states.acceptance_status_id' => AcceptanceStatus['Accepted'], 'person_con_states.invitestatus_id' => InviteStatus['Invited'] }
    whereClause[:id] = peopleIds if peopleIds
    
    if (tag)
      # takes options
      Person.tagged_with(tag, :on => 'PrimaryArea', :op => true).where(whereClause).includes([:pseudonym, :bio_image, :edited_bio]).
              where(self.constraints()).
              joins(:person_con_state).
              order("people.last_name")
    else  
      Person.where(whereClause).includes([:pseudonym, :bio_image, :edited_bio]).
              where(self.constraints()).
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
    Person.where(self.constraints()).all :conditions => conditions, 
              :joins => { :programmeItemAssignments => {} },
              :include => {:pseudonym => {}, :programmeItemAssignments => {:programmeItem => {}} },
              :order => "people.last_name"

  end
  
  #
  #
  #
  def self.findAllPeopleByInviteAndAcceptance(invitestatus = nil, acceptance = nil)
    stateTable = Arel::Table.new(:person_con_states)
    peopleTable = Arel::Table.new(:people)
    query = nil
    
    if invitestatus || acceptance
      include_list = [:pseudonym, :email_addresses, :postal_addresses, :person_con_state,
                      {:programmeItemAssignments => {:programmeItem => [:time_slot, :format]}}
                    ]
      query = stateTable[:invitestatus_id].eq(invitestatus) if invitestatus
      
      if acceptance
        if query
          query = query.and(stateTable[:acceptance_status_id].eq(acceptance))
        else
          query = stateTable[:acceptance_status_id].eq(acceptance)
        end
      end
    else  
      include_list = [:pseudonym, :email_addresses, :postal_addresses,
                      {:programmeItemAssignments => {:programmeItem => [:time_slot, :format]}}
                    ]
    end
    
    Person.joins(:person_con_state).
                            includes(include_list).
                            where(query).
                            where(self.constraints()).
                            order("people.last_name, people.first_name")
  end
  
  #
  # need invitation_status, invitation_category
  #
  def self.findAllPeople(invitestatus = nil, invite_category = nil)
    stateTable = Arel::Table.new(:person_con_states)
    peopleTable = Arel::Table.new(:people)
    regTable = Arel::Table.new(:registration_details)
    assignments = Arel::Table.new(:programme_item_assignments)
    query = nil
    
    # Get people for conference
    # i.e. if they have registrations or item assignments
    join_query = peopleTable.join(stateTable, Arel::Nodes::OuterJoin).
                    on(
                      stateTable[:person_id].eq(peopleTable[:id]).and(
                        self.arel_constraints(PersonConState)
                      )
                    ).join(regTable, Arel::Nodes::OuterJoin). # Look at the registration data
                    on(
                      regTable[:person_id].eq(peopleTable[:id]).and(
                        self.arel_constraints(RegistrationDetail)
                      )
                    ).join(assignments, Arel::Nodes::OuterJoin). # Look at the item assignment data
                    on(
                      assignments[:person_id].eq(peopleTable[:id]).and(
                        self.arel_constraints(ProgrammeItemAssignment)
                      )
                    ).
                    join_sources

    query = stateTable[:invitestatus_id].eq(invitestatus) if invitestatus && invitestatus > 0
    query = query.and(stateTable[:invitation_category_id].eq(invite_category)) if invite_category && invite_category > 0
    
    include_list = [:pseudonym, :email_addresses, :postal_addresses, :programmeItemAssignments]
    
    Person.joins(join_query).
                includes(include_list).
                where(query).
                uniq.
                order("people.last_name")
  end

  #
  #
  #
  def self.countPeople(filters = nil, extraClause = nil, onlySurveyRespondents = false, nameSearch=nil, context=nil, tags = nil, page_to = nil, mailing_id=nil, op=nil,
                        scheduled=false, includeMailings=false, includeMailHistory=false, email = nil)
    args = genArgsForSql(nameSearch, mailing_id, op, scheduled, filters, extraClause, onlySurveyRespondents, page_to, includeMailings, includeMailHistory, email)
    tagquery = DataService.genTagSql(context, tags)

    includes = [:pseudonym, :email_addresses]
    # includes << :invitation_category if DataService.getFilterData( filters, 'invitation_category_id' )
    args.merge! :include => includes

    if tagquery.empty?
      Person.where(self.constraints(includeMailings, includeMailHistory, mailing_id, onlySurveyRespondents, filters, extraClause)).uniq.count args
    else
      Person.tagged_with(*tagquery).uniq.where(self.constraints(includeMailings, includeMailHistory, mailing_id, onlySurveyRespondents, filters, extraClause)).uniq.count args
      # eval %Q[Person#{tagquery}.where(#{self.constraints(includeMailings,includeMailHistory,mailing_id,onlySurveyRespondents,filters,extraClause)}).uniq.count( :all, ] + args.inspect + ")"
    end
  end

  #
  #
  #
  def self.findPeople(rows=15, page=1, index='last_name', sort_order='asc', filters = nil, extraClause = nil,
                        onlySurveyRespondents = false, nameSearch=nil, context=nil, tags = nil, mailing_id=nil, op=nil, 
                        scheduled=false, includeMailings=false, includeMailHistory=false, email = nil)
    args = genArgsForSql(nameSearch, mailing_id, op, scheduled, filters, extraClause, onlySurveyRespondents, nil, includeMailings, includeMailHistory, email)
    tagquery = DataService.genTagSql(context, tags)
    
    offset = (page - 1) * rows.to_i
    offset = 0 if offset < 0
    args.merge!(:offset => offset, :limit => rows)
    if index
      args.merge!(:order => index + " " + sort_order)
    end
    
    includes = [:pseudonym, :email_addresses]
    # includes << :invitation_category if DataService.getFilterData( filters, 'invitation_category_id' )
    args.merge! :include => includes
    
    if tagquery.empty?
      people = Person.where(self.constraints(includeMailings, includeMailHistory, mailing_id, onlySurveyRespondents, filters, extraClause)).includes(:pseudonym).uniq.all args
    else
      people = Person.tagged_with(*tagquery).uniq.where(self.constraints(includeMailings, includeMailHistory, mailing_id, onlySurveyRespondents, filters, extraClause)).includes(:pseudonym).uniq.all args
      # people = eval %Q[Person#{tagquery}.uniq.where(#{self.constraints(includeMailings,includeMailHistory,mailing_id,onlySurveyRespondents,filters,extraClause)}).includes(:pseudonym).uniq.find :all, ] + args.inspect
    end
  end
  
  private
  
  #
  #
  #
  def self.genArgsForSql(nameSearch, mailing_id, op, scheduled, filters, extraClause, onlySurveyRespondents, page_to = nil, includeMailings=false, includeMailHistory=false, email=nil)
    includeConState = false
    clause = DataService.createWhereClause(filters, 
          ['person_con_states.invitestatus_id', 'person_con_states.invitation_category_id', 'person_con_states.acceptance_status_id', 'mailing_id'],
          ['person_con_states.invitestatus_id', 'person_con_states.invitation_category_id', 'person_con_states.acceptance_status_id', 'mailing_id'], ['people.last_name'],
          {'person_con_states.acceptance_status_id' => '6', 'person_con_states.invitestatus_id' => '1'})

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
      includeConState = extraClause['param'].to_s.include?('person_con_states')
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

    clause = DataService.addClause( clause, 'email_addresses.email like ?', '%' + email + '%') if email

    # if the where clause contains pseudonyms. then we need to add the join
    args = { :conditions => clause }

    if args[:joins]
      args[:joins] += conStateJoinString
    else  
      args.merge!( :joins => conStateJoinString )
    end

    if includeMailings && clause && (clause[0].include? "mailing_id")
      if args[:joins]
        args[:joins] += ' LEFT JOIN person_mailing_assignments on people.id = person_mailing_assignments.person_id'
      else  
        args.merge!( :joins => 'LEFT JOIN person_mailing_assignments on people.id = person_mailing_assignments.person_id' )
      end
    end

    if includeMailHistory && clause && (clause[0].include? "mailing_id")
      if args[:joins]
        args[:joins] += ' LEFT JOIN mail_histories on people.id = mail_histories.person_id and mail_histories.testrun = 0'
      else  
        args.merge!( :joins => 'LEFT JOIN mail_histories on people.id = mail_histories.person_id and mail_histories.testrun = 0' )
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
  
  def self.conStateJoinString
    ' LEFT OUTER JOIN person_con_states on person_con_states.person_id = people.id LEFT OUTER JOIN registration_details on registration_details.person_id = people.id'
  end
  
  def self.constraints(*args)
    true
  end
  
  def self.arel_constraints(*args)
    true
  end
  
end
