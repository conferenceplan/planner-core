#
#
#
module ImportService
  require 'csv'
  
  # given an id from the pending table return a list of people that could be a match
  def self.getPossibleMatches(pending_id)
    people = Arel::Table.new(:people)
    pending_import_people = Arel::Table.new(:pending_import_people)
    peoplesources = Arel::Table.new(:peoplesources)

    attrs = [people[:id].as('person_id')]
    
    query = pending_import_people.project(*attrs).
              where(pending_import_people[:id].eq(pending_id)).
              where(self.constraints()).
              join(people, Arel::Nodes::OuterJoin).
                on(people[:first_name].eq(pending_import_people[:first_name]).
                and(people[:last_name].eq(pending_import_people[:last_name]))).
              join(peoplesources, Arel::Nodes::OuterJoin).
                on(peoplesources[:person_id].eq(people[:id])).
              order(pending_import_people[:id])

    people_ids = ActiveRecord::Base.connection.select_all(query.to_sql)

    query = pending_import_people.project(*attrs).
              where(pending_import_people[:id].eq(pending_id)).
              where(self.constraints()).
              join(peoplesources).
                on(peoplesources[:datasource_dbid].eq(pending_import_people[:datasource_dbid]).and(peoplesources[:datasource_dbid].not_eq(nil))).
              join(people, Arel::Nodes::OuterJoin).
                on(people[:id].eq(peoplesources[:person_id])).
              order(pending_import_people[:id])

    people_ids += ActiveRecord::Base.connection.select_all(query.to_sql)

    Person.where(id: people_ids.collect{|a| a["person_id"] })
  end
  
  # Take the CSV file and import it into the pending table
  def self.importCSVtoPending(filename, mapping, datasource_id, ignore_first_line = false)
    Person.transaction do
      # Get the mappings from the database and convert into suitable form for the query
      fields = []
      mapping.attributes.collect{|name,val| fields[val] = name if ((["lock_version", "created_at", "updated_at", "id", "datasource_id"].index(name) == nil) && ((val != nil) && (val != -1))) }
      
      sampler = EncodingSampler::Sampler.new(filename, ['ASCII-8BIT', 'UTF-8', 'ISO-8859-1', 'ISO-8859-2', 'ISO-8859-15'])
      
      # logger.debug sampler.valid_encodings
      
      if ! sampler.valid_encodings.include?('UTF-8')
        # then convert the file
        # string.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")
        text = File.read(filename)
        replace = text.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "")
        File.open(filename, "w") {|file| file.puts replace}
      end

      # we need to take into account the different types of line endings \r \n and \r\n
      # so make sure all the files are the same for eol
      text = File.read(filename)
      replace = text.gsub(/\r\n?/, "\n")
      File.open(filename, "w") {|file| file.puts replace}
      
      # Examine the file to figure out its character encoding
      # get the number of columns in the file      
      nbr_of_cols = 0
      CSV.foreach(filename) do |row|
        nbr_of_cols = row.size
        break
      end

      # and now do the conversion      
      eolChar = '\\n'
      extras = Array.new(nbr_of_cols - fields.size, '@dummy')
      extra_cols = extras.join(",")
      query = "load data LOCAL infile '" + 
              filename + 
              "' replace into table pending_import_people FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '\\\\' " +
              " LINES TERMINATED BY '" + eolChar + "' STARTING BY '' " +
              (ignore_first_line ? "IGNORE 1 LINES" : "") +
              "(" + 
              fields.collect{|f| f ? f : '@dummy' }.join(",") + (extra_cols.blank? ? "" : "," + extra_cols) +
              ") SET datasource_id = " + datasource_id.to_s + 
              ", updated_at = NOW(), created_at = NOW()" + extra_set + ";"
      
      ActiveRecord::Base.connection.execute(query)
      
      # If the name is empty we should remove those records
      ActiveRecord::Base.connection.execute(
              "delete from pending_import_people where id in (select id from (select id from pending_import_people pi where (last_name is null OR last_name = '') and (first_name is null OR first_name = '')) a);"
            )
            
      # Check for duplicates in the pending table - get rid of the older ones
      # ActiveRecord::Base.connection.execute(
              # "delete from pending_import_people where id not in (select * from  (select max(id) from pending_import_people pi group by pi.datasource_id, pi.datasource_dbid, pi.first_name, pi.last_name ) a);"
            # )
      
    end
  end
  
  # Assess the content of the Pending table to see what needs to be done (imported etc)
  # NOTE: ActiveRecord::Base.connection.quote("help'dd'")
  def self.processPendingImports(datasource_id)
    Person.transaction do
      
      datasource = Datasource.find(datasource_id)


      # If the name and regid is not found then this is a new entry INSERT
      # Otherwise it is a update or potential update
      # SAME Datasource SAME reg id SAME name : Update ONLY if allowed OTHERWISE potential match
      # All other permutations are a POTENTIAL match and need a review    
      # SAME Datasource SAME reg id DIFFENT name
      # SAME Datasource DIFFERENT reg id SAME name
      # DIFFERENT Datasource SAME reg id SAME name
      # DIFFERENT Datasource SAME reg id DIFFENT name
      # DIFFERENT Datasource DIFFERENT reg id SAME name
    
      ActiveRecord::Base.connection.execute(@@UPDATE_IMPORT_STATES_NAME_1 +
                        constraint() +
                        @@UPDATE_IMPORT_STATES_NAME_2 +
                        PendingType['PossibleMatchExisting'].id.to_s +
                        @@UPDATE_IMPORT_STATES_NAME2 +
                        PendingType['RegistrationInUse'].id.to_s +
                        @@UPDATE_IMPORT_STATES_NAME22 +
                        PendingType['PossibleMatchExisting'].id.to_s +
                        @@UPDATE_IMPORT_STATES_NAME3 +
                        PendingType['PossibleMatchExisting'].id.to_s +
                        @@UPDATE_IMPORT_STATES_NAME4
      );

      ActiveRecord::Base.connection.execute(@@UPDATE_IMPORT_STATES_DBID_1 +
                        constraint() +
                        @@UPDATE_IMPORT_STATES_DBID_2 +
                        PendingType['PossibleNameUpdate'].id.to_s +
                        @@UPDATE_IMPORT_STATES_DBID2 +
                        PendingType['PossibleMatchExisting'].id.to_s +
                        @@UPDATE_IMPORT_STATES_DBID3
      );
      
      # And now go through the import table and do the inserts etc.
      
      # Select where the pending_type_id is null and insert into people (and count)
      PendingImportPerson.where(:pendingtype_id => nil).each do |candidate|
        createPerson candidate, datasource
      end
      nbr_created = PendingImportPerson.where(:pendingtype_id => nil).delete_all
              
      # Report on what has been done and what is left to the user
      {
        :created => nbr_created,
        :updates => 0,
        :possible_matches => PendingImportPerson.where(:pendingtype_id => PendingType['PossibleMatchExisting'].id).count,
        :registration_in_use => PendingImportPerson.where(:pendingtype_id => PendingType['RegistrationInUse'].id).count,
        :possible_name_updates => PendingImportPerson.where(:pendingtype_id => PendingType['PossibleNameUpdate'].id).count
      }
    end
  end
  
  # Merge all that have a single match
  def self.mergeAllPending()
    matches = getSinglePossibleMatches
    matches.each do |match|
      # match contains the person and pending
      pending = PendingImportPerson.find match['pending_id']
      person = Person.find match['person_id']
      copy_person pending, person
      pending.delete
    end
  end

  # Merge the pending with the specified person
  def self.mergePending(pending_id, person_id)
    pending = PendingImportPerson.find pending_id
    person = Person.find person_id
    copy_person pending, person
    pending.delete
  end

  # create a new entry from the pending person
  def self.newFromPending(pending_id)
    pending = PendingImportPerson.find pending_id
    createPerson pending, pending.datasource
    pending.delete
  end

#
#
#
protected

  # Get all the people where there was only one match
  def self.getSinglePossibleMatches()
    people = Arel::Table.new(:people)
    pending_import_people = Arel::Table.new(:pending_import_people)
    peoplesources = Arel::Table.new(:peoplesources)

    attrs = [people[:id].as('person_id'), pending_import_people[:id].as('pending_id')]
    
    query = pending_import_people.project(*attrs).
              join(people, Arel::Nodes::OuterJoin).
                on(people[:first_name].eq(pending_import_people[:first_name]).
                and(people[:last_name].eq(pending_import_people[:last_name]))).
              join(peoplesources, Arel::Nodes::OuterJoin).
                on(peoplesources[:person_id].eq(people[:id])).where(self.arel_constraints()).
              group(pending_import_people[:id]).having(pending_import_people[:id].count.eq(1))

    result = ActiveRecord::Base.connection.select_all(query.to_sql)

    # Person.where(id: people_ids.collect{|a| a["person_id"] })
  end

  # Given an entry from the pending table that we know is an insert create that person
  def self.createPerson(pendingPerson, datasource = nil)
    
    # Create the person
    person = Person.new(
          :first_name => pendingPerson.first_name,
          :last_name => pendingPerson.last_name,
          :suffix => pendingPerson.suffix,
          :prefix => pendingPerson.prefix,
          :company => pendingPerson.company,
          :job_title => pendingPerson.job_title
        )
    person.save!

    if datasource
      peoplesource = Peoplesource.new({ :person_id => person.id, :datasource_id => datasource.id, :datasource_dbid => pendingPerson.datasource_dbid })
      peoplesource.save!
    end
    
    person.person_con_state = PersonConState.new
    
    # Check the state fields from pending import
    
    person.person_con_state.save!
    
    copy_person(pendingPerson, person)
    
  end
  
  def self.copy_person(pendingPerson, person)
    # Create the reg info
    if pendingPerson.registration_number || pendingPerson.registration_type
      if !person.registrationDetail
        person.registrationDetail = RegistrationDetail.new(
              :registration_number => pendingPerson.registration_number,
              :registration_type => pendingPerson.registration_type,
              :registered => true
          )
      else  
        person.registrationDetail.update_attributes(
              :registration_number => pendingPerson.registration_number,
              :registration_type => pendingPerson.registration_type,
              :registered => true
        )
      end
      person.registrationDetail.save!
    end

    person.suffix = pendingPerson.suffix
    person.first_name = pendingPerson.first_name
    person.last_name = pendingPerson.last_name
    person.prefix = pendingPerson.prefix
    person.save!

    peoplesource = person.peoplesource
    if peoplesource
      peoplesource.datasource_id = pendingPerson.datasource_id
      peoplesource.datasource_dbid = pendingPerson.datasource_dbid
    else 
      peoplesource = Peoplesource.new({ :person_id => person.id, :datasource_id => pendingPerson.datasource_id, :datasource_dbid => pendingPerson.datasource_dbid })
    end
    peoplesource.save!
    
    # Create the pseudonym
    if !pendingPerson.pseudonymNil?
      if !person.pseudonym
        person.pseudonym = Pseudonym.new(
              :first_name => pendingPerson.pub_first_name,
              :last_name => pendingPerson.pub_last_name,
              :suffix => pendingPerson.pub_suffix,
              :prefix => pendingPerson.pub_prefix
            )
      else  
        person.pseudonym.update_attributes(
              :first_name => pendingPerson.pub_first_name,
              :last_name => pendingPerson.pub_last_name,
              :suffix => pendingPerson.pub_suffix,
              :prefix => pendingPerson.pub_prefix
            )
      end
      person.pseudonym.save!
    end
    
    person.suffix = pendingPerson.suffix
    person.first_name = pendingPerson.first_name
    person.last_name = pendingPerson.last_name
    person.prefix = pendingPerson.prefix
    person.save!
    
    # Create the address, email & phone
    if !pendingPerson.addressNil?
      # TODO - CHECK
      postal = person.getDefaultPostalAddress
      if postal
        postal.update_attributes(
            :line1 => (pendingPerson.line1.blank? ? postal.line1 : pendingPerson.line1), 
            :line2 => (pendingPerson.line2.blank? ? postal.line2 : pendingPerson.line2), 
            :line3 => (pendingPerson.line3.blank? ? postal.line3 : pendingPerson.line3), 
            :city => (pendingPerson.city.blank? ? postal.city : pendingPerson.city), 
            :state => (pendingPerson.state.blank? ? postal.state : pendingPerson.state ), 
            :postcode => (pendingPerson.postcode.blank? ? postal.postcode : pendingPerson.postcode), 
            :country => (pendingPerson.country.blank? ? postal.country : pendingPerson.country), 
            :isdefault => true
          );
      else  
        postal = person.postal_addresses.new(
            :line1 => (pendingPerson.line1.blank? ? "" : pendingPerson.line1), 
            :line2 => (pendingPerson.line2.blank? ? "" : pendingPerson.line2), 
            :line3 => (pendingPerson.line3.blank? ? "" : pendingPerson.line3), 
            :city => (pendingPerson.city.blank? ? "" : pendingPerson.city), 
            :state => (pendingPerson.state.blank? ? "" : pendingPerson.state), 
            :postcode => (pendingPerson.postcode.blank? ? "" : pendingPerson.postcode), 
            :country => (pendingPerson.country.blank? ? "" : pendingPerson.country), 
            :isdefault => true
          );
      end
      person.save!
    end
    
    if !pendingPerson.emailNil?
      # TODO - CHECK
      email = person.getDefaultEmail
      if email
        email.update_attributes(
            :email => pendingPerson.email,
            :isdefault => true
          );
      else  
        email = person.email_addresses.new(
            :email => pendingPerson.email,
            :isdefault => true
          );
      end
      person.save!
    end
    
    if !pendingPerson.phoneNil?
      person.updatePhone(pendingPerson.phone, PhoneTypes['Work'].name)
      person.save!
    end    

    # and the bio
    if !pendingPerson.bio.blank?
      person.edited_bio = EditedBio.new if !person.edited_bio
      person.edited_bio.bio = pendingPerson.bio
      person.edited_bio.save!
    end
    
    if !pendingPerson.invite_status.blank?
      invite_status = Enum.where({'name' => pendingPerson.invite_status, :type => InviteStatus.name}).first
      person.invitestatus_id = invite_status.id if invite_status
    end

    if !pendingPerson.accept_status.blank?
      accept_status = Enum.where({'name' => pendingPerson.accept_status, :type => AcceptanceStatus.name}).first
      person.acceptance_status_id = accept_status.id if accept_status
    end

    if !pendingPerson.invite_category.blank?
      invite_category = InvitationCategory.where({'name' => pendingPerson.invite_category}).first
      person.invitation_category_id = invite_category.id if invite_category
    end

  end

  def self.extra_set()
    ' '
  end

  def self.constraints(*args)
    true
  end

  def self.arel_constraints(*args)
    true
  end
  

  def self.constraint()
    ' '
  end

#
#
#

@@UPDATE_IMPORT_STATES_NAME_1 = <<"EOS"
  update pending_import_people pip,(
    select pending_import_people.id, pending_import_people.datasource_id, pending_import_people.datasource_dbid,
    count(people.id) matches, peoplesources.datasource_id people_did, peoplesources.datasource_dbid people_dbid
    from pending_import_people
    left outer join people
    on pending_import_people.first_name = people.first_name 
    and pending_import_people.last_name = people.last_name
    left join peoplesources on peoplesources.person_id = people.id
EOS

@@UPDATE_IMPORT_STATES_NAME_2 = <<"EOS"
    group by pending_import_people.id
  ) cand
  set pendingtype_id = case
      when (cand.matches = 1 AND cand.datasource_id = cand.people_did AND cand.datasource_dbid = cand.people_dbid ) then 
EOS

@@UPDATE_IMPORT_STATES_NAME2 = <<"EOS"    
      when (cand.matches = 1 AND (cand.datasource_id != cand.people_did OR cand.datasource_dbid != cand.people_dbid) ) then 
EOS

# TODO we need to deal with the case when the user does not specify a dbid - then it is case 2 registration in use
@@UPDATE_IMPORT_STATES_NAME22 = <<"EOS"    
      when (cand.matches = 1 AND (cand.datasource_dbid is null) ) then 
EOS

@@UPDATE_IMPORT_STATES_NAME3 = <<"EOS"    
      when (cand.matches > 1) then
EOS

@@UPDATE_IMPORT_STATES_NAME4 = <<"EOS"    
    end
  where pip.id = cand.id
EOS

# After the following - null == insert
@@UPDATE_IMPORT_STATES_DBID_1 = <<"EOS"
  update pending_import_people pip,(
    select pending_import_people.id, count(peoplesources.id) matches, 
    people.first_name, people.last_name, 
    pending_import_people.first_name import_first_name, pending_import_people.last_name import_last_name
    from pending_import_people
    left join peoplesources on peoplesources.datasource_id = pending_import_people.datasource_id
    AND peoplesources.datasource_dbid = pending_import_people.datasource_dbid
    left join people on people.id = peoplesources.person_id
EOS
    
@@UPDATE_IMPORT_STATES_DBID_2 = <<"EOS"
    group by pending_import_people.id, peoplesources.id
  ) cand
  set pendingtype_id = case
      when (cand.matches = 1 AND (cand.first_name != cand.import_first_name OR cand.last_name != cand.import_last_name) ) then 
EOS

@@UPDATE_IMPORT_STATES_DBID2 = <<"EOS"
      when (cand.matches > 1) then 
EOS

@@UPDATE_IMPORT_STATES_DBID3 = <<"EOS"
      else pendingtype_id
    end
  where pip.id = cand.id
EOS

end
