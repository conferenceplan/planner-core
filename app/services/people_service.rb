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
      if !dest_person.survey_respondent || !dest_person.survey_respondent.survey_respondent_detail
        candidate = dest_person.survey_respondent
        survey_respondent = src_person.survey_respondent
        survey_respondent.person = dest_person
        survey_respondent.save

        if candidate
          candidate.person = nil
          candidate.delete # TODO - test
        end
      else
        # move each of the surveys
        src_detail = src_person.survey_respondent.survey_respondent_detail
        dest_detail = dest_person.survey_respondent.survey_respondent_detail

        if src_detail
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
            else # else merge in the responses???
              src_detail.getResponses(survey.id).each do |response|
                if !dest_detail.getResponse(survey.id, response.survey_question_id)
                  response.survey_respondent_detail = dest_detail
                  response.save
                end
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
    
    cndStr = "programme_items.visibility_id != #{Visibility['None'].id}"

    conditions = [cndStr] #, [AcceptanceStatus['Accepted'].id, AcceptanceStatus['Probable'].id]]

    # TODO - should this be from the published items rather than the pre-published?
    # TODO - need to test that programme item assignments actually exist
    Person.where(self.constraints()).
                references({:pseudonym => {}, :programmeItemAssignments => {:programmeItem => {}} }).
                joins(:programmeItemAssignments).
                where(conditions).
                includes({:pseudonym => {}, :programmeItemAssignments => {:programmeItem => {}} }).
                order("people.last_name")
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
  def self.findAllPeople(invitestatus = nil, invite_category = nil, only_relevant_people = false)
    stateTable = Arel::Table.new(:person_con_states)
    peopleTable = Arel::Table.new(:people)
    regTable = Arel::Table.new(:registration_details)
    assignments = Arel::Table.new(:programme_item_assignments)
    query = nil
    people_filter = only_relevant_people ? only_relevent_clause : ''
    
    # Get people for conference
    # i.e. if they have registrations or item assignments
    state_join = stateTable[:person_id].eq(peopleTable[:id])
    state_join = state_join.and(self.arel_constraints(PersonConState)) if self.arel_constraints(PersonConState)

    reg_join = regTable[:person_id].eq(peopleTable[:id])
    reg_join = reg_join.and(self.arel_constraints(RegistrationDetail)) if self.arel_constraints(RegistrationDetail)
    
    assignment_join = assignments[:person_id].eq(peopleTable[:id])
    assignment_join = assignment_join.and(self.arel_constraints(ProgrammeItemAssignment)) if self.arel_constraints(ProgrammeItemAssignment)
    
    join_query = peopleTable.join(stateTable, Arel::Nodes::OuterJoin).
                      on(state_join).
                    join(regTable, Arel::Nodes::OuterJoin). # Look at the registration data
                      on(reg_join).
                    join(assignments, Arel::Nodes::OuterJoin). # Look at the item assignment data
                      on(assignment_join).
                    join_sources

    query = stateTable[:invitestatus_id].eq(invitestatus) if invitestatus && invitestatus > 0
    if invite_category && invite_category > 0
      if query
        query = query.and(stateTable[:invitation_category_id].eq(invite_category))
      else  
        query = stateTable[:invitation_category_id].eq(invite_category)
      end
    end
    
    include_list = [:pseudonym, :person_con_state, :survey_respondent,
                    :registrationDetail,
                    :email_addresses, :postal_addresses, :programmeItemAssignments,
                    :mailings]

    Person.joins(join_query).
              joins(only_relevent_joins).
              includes(include_list).
              references(include_list).
              where(people_filter).
              where(query).
              distinct.
              order("people.last_name")
  end

  #
  #
  #
  def self.countPeople(filters: nil, extra_clause: nil, only_survey_respondents: false, 
      name_search: nil, context: nil, tags: nil, page_to: nil, mailing_id: nil, 
      op: nil, scheduled: false, include_mailings: false, include_mail_history: false, 
      email: nil, only_relevant_people: false, excluded_person_ids: nil)

    query = where_clause(name_search, mailing_id, op, scheduled, filters, extra_clause, only_survey_respondents, page_to, include_mailings, include_mail_history, email)
    tagquery = DataService.genTagSql(context, tags)

    people_filter = only_relevant_people ? only_relevent_clause : ''
    
    included = [:pseudonym, :person_con_state, :survey_respondent, :registrationDetail, :mailings, :programmeItemAssignments]
    included << :email_addresses if email && !email.blank?

    if tagquery.empty?
      # Rails.logger.warn Person.
            # includes(included).
            # where(self.constraints(include_mailings, include_mail_history, mailing_id, only_survey_respondents, filters, extra_clause)).
            # where(query).
            # where(people_filter).
            # references(included).
            # joins(only_relevent_joins).
            # distinct.explain
      Person.
            includes(included).
            where(self.constraints(include_mailings, include_mail_history, mailing_id, only_survey_respondents, filters, extra_clause)).
            where(query).
            where(people_filter).
            where.not(id: excluded_person_ids).
            references(included).
            joins(only_relevent_joins).
            distinct.count
    else
      Person.tagged_with(*tagquery).distinct.
            includes(included).
            where(self.constraints(include_mailings, include_mail_history, mailing_id, only_survey_respondents, filters, extra_clause)).
            where(query).
            where(people_filter).
            where.not(id: excluded_person_ids).
            references(included).
            joins(only_relevent_joins).
            distinct.count
    end
  end

  #
  #
  #
  def self.findPeople(rows: 15, page: 1, index:'last_name', sort_order: 'asc', 
      filters: nil, extra_clause: nil, only_survey_respondents: false, 
      name_search: nil, context: nil, tags: nil, page_to: nil, mailing_id: nil, 
      op: nil, scheduled: false, include_mailings: false, include_mail_history: false, 
      email: nil, only_relevant_people: false, excluded_person_ids: nil)
# TODO - FIX NilClass       undefined local variable or method `page_to' for PeopleService:Module                 
    query = where_clause(name_search, mailing_id, op, scheduled, filters, extra_clause, only_survey_respondents, page_to, include_mailings, include_mail_history, email)
    tagquery = DataService.genTagSql(context, tags)
    
    offset = (page - 1) * rows.to_i
    offset = 0 if offset < 0

    sort_order = ""
    if index
      sort_order = index + " " + sort_order
    end
    
    # includes = [:pseudonym, :email_addresses]
    # # includes << :invitation_category if DataService.getFilterData( filters, 'invitation_category_id' )
    # args.merge! :include => includes

    people_filter = only_relevant_people ? only_relevent_clause : ''
    
    if tagquery.empty?
      people = Person.where(self.constraints(include_mailings, include_mail_history, mailing_id, only_survey_respondents, filters, extra_clause)).
                  includes([:pseudonym, :email_addresses, :person_con_state, :survey_respondent, :registrationDetail, :mailings, :programmeItemAssignments]).
                  where(query).
                  where(people_filter).
                  where.not(id: excluded_person_ids).
                  references([:pseudonym, :email_addresses, :person_con_state, :survey_respondent, :registrationDetail, :mailings, :programmeItemAssignments]).
                  joins(only_relevent_joins).
                  order(sort_order).
                  offset(offset).
                  limit(rows).
                  distinct
    else
      people = Person.tagged_with(*tagquery).
                  distinct.
                  includes([:pseudonym, :email_addresses, :person_con_state, :survey_respondent, :registrationDetail, :mailings, :programmeItemAssignments]).
                  where(self.constraints(include_mailings, include_mail_history, mailing_id, only_survey_respondents, filters, extra_clause)).
                  where(query).
                  where(people_filter).
                  where.not(id: excluded_person_ids).
                  references([:pseudonym, :email_addresses, :person_con_state, :survey_respondent, :registrationDetail, :mailings, :programmeItemAssignments]).
                  joins(only_relevent_joins).
                  order(sort_order).
                  offset(offset).
                  limit(rows).
                  distinct
    end
  end
  
  private
  
  # The person has "tickets" or orders
  # the person has sign ups to items
  def self.only_relevent_clause
    # person_mailing_assignments.id is not null - covered by mailing....
    q = ["person_con_states.id is not null or registration_details.id is not null or programme_item_assignments.id is not null or survey_respondents.id is not null or mailings.id is not null"]
  
    q
  end
  
  def self.only_relevent_joins
    nil
  end
  
  def self.where_clause(name_search, mailing_id, op, scheduled, filters, extra_clause, only_survey_respondents, page_to = nil, 
                        include_mailings=false, include_mail_history=false, email=nil)
    includeConState = false
    clause = DataService.createWhereClause(filters, 
          ['person_con_states.invitestatus_id', 'person_con_states.invitation_category_id', 'person_con_states.acceptance_status_id', 'mailing_id'],
          ['person_con_states.invitestatus_id', 'person_con_states.invitation_category_id', 'person_con_states.acceptance_status_id', 'mailing_id'], ['people.last_name'],
          {'person_con_states.acceptance_status_id' => '6', 'person_con_states.invitestatus_id' => '1'})

    # add the name search for last of first etc
    if name_search #&& ! name_search.empty?
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
    
    if extra_clause
      if (extra_clause['value'].include? ',')
        vals  = extra_clause['value'].split(',')
        clause = DataService.addClause( clause, extra_clause['param'].to_s + ' in (?)', vals)
      else
        # TODO - change to like for regdetails
        clause = DataService.addClause( clause, extra_clause['param'].to_s + ' = ?', extra_clause['value'].to_s)
      end
      includeConState = extra_clause['param'].to_s.include?('person_con_states')
    end

    # Find people that do not have the specified mailing id
    # TODO - need the not in as well
    mailingQuery = 'people.id '
    mailingQuery += op if op
    mailingQuery +=  ' in (select person_id from person_mailing_assignments where mailing_id = ?)'
    clause = DataService.addClause( clause, mailingQuery, mailing_id) if mailing_id && ! mailing_id.empty?
    
    clause = DataService.addClause( clause, 'people.last_name <= ?', page_to) if page_to && !page_to.empty?
    
    # Then we want to filter for scehduled people
    # select distinct person_id from programme_item_assignments;
    clause = DataService.addClause( clause, 'people.id in (select distinct person_id from room_item_assignments ra join programme_item_assignments pa on pa.programme_item_id = ra.programme_item_id)', nil) if scheduled

    clause = DataService.addClause( clause, 'email_addresses.email like ?', '%' + email + '%') if email && !email.blank?

    clause    
  end

  def self.constraints(*args)
    nil
  end
  
  def self.arel_constraints(*args)
    nil
  end
  
end
