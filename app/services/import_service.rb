#
#
#
module ImportService
  require 'csv'
  
  # Take the CSV file and import it into the pending table
  def self.importCSVtoPending(filename, mapping, datasource_id, ignore_first_line = false)
    Person.transaction do
      # Get the mappings from the database and convert into suitable form for the query
      fields = []
      mapping.attributes.collect{|name,val| fields[val] = name if (["lock_version", "created_at", "updated_at", "id", "datasource_id"].index(name) == nil) && val != nil }
  
      # TODO - we need to take into account the different types of line endings \r \n and \r\n
      eolChar = '\\n'
      query = "load data infile '" + 
              filename + 
              "' replace into table pending_import_people FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '\\\\' " +
              " LINES TERMINATED BY '" + eolChar + "' STARTING BY '' " +
              (ignore_first_line ? "IGNORE 1 LINES" : "") +
              "(" + 
              fields.collect{|f| f ? f : '@dummy' }.join(",") + 
              ") SET datasource_id = " + datasource_id.to_s + 
              ", updated_at = NOW(), created_at = NOW();"
      
      ActiveRecord::Base.connection.execute(query)
      
      # If the name is empty we should remove those records
      ActiveRecord::Base.connection.execute(
              "delete from pending_import_people where id in (select id from (select id from pending_import_people pi where (last_name is null OR last_name = '') and (first_name is null OR first_name = '')) a);"
            )
            
      # Check for duplicates in the pending table - get rid of the older ones
      ActiveRecord::Base.connection.execute(
              "delete from pending_import_people where id not in (select * from  (select max(id) from pending_import_people pi group by pi.datasource_id, pi.datasource_dbid, pi.first_name, pi.last_name ) a);"
            )
      
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
    
      #        -1 IIF ALLOWED else PossibleMatchExisting
      ActiveRecord::Base.connection.execute(@@UPDATE_IMPORT_STATES_NAME +
                        PendingType['PossibleMatchExisting'].id.to_s +
                        @@UPDATE_IMPORT_STATES_NAME2 +
                        PendingType['RegistrationInUse'].id.to_s +
                        @@UPDATE_IMPORT_STATES_NAME3 +
                        PendingType['PossibleMatchExisting'].id.to_s +
                        @@UPDATE_IMPORT_STATES_NAME4
      );

      ActiveRecord::Base.connection.execute(@@UPDATE_IMPORT_STATES_DBID +
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
        
      # Select where the pending_type_id is -1 and update into people (and count) - update address info and reg status (and pub name?)
      # candidates = PendingImportPerson.where(:pendingtype_id => -1) TODO

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

#
#
#
protected

    # Given an entry from the pending table that we know is an insert create that person
    def self.createPerson(pendingPerson, datasource)
      
      # Create the person
      person = Person.new(
            :first_name => pendingPerson.first_name,
            :last_name => pendingPerson.last_name,
            :suffix => pendingPerson.suffix,
            :company => pendingPerson.company,
            :job_title => pendingPerson.job_title
          )
      person.save!
          
      peoplesource = Peoplesource.new({ :person_id => person.id, :datasource_id => datasource.id, :datasource_dbid => pendingPerson.datasource_dbid })
      peoplesource.save!

      # Create the reg info
      if pendingPerson.registration_number && pendingPerson.registration_type
        person.registrationDetail = RegistrationDetail.new(
              :registration_number => pendingPerson.registration_number,
              :registration_type => pendingPerson.registration_type,
              :registered => true
          )
        person.registrationDetail.save!
      end
      
      # Create the pseudonym
      if !pendingPerson.pseudonymNil?
        person.pseudonym = Pseudonym.new(
              :first_name => pendingPerson.pub_first_name,
              :last_name => pendingPerson.pub_last_name,
              :suffix => pendingPerson.pub_suffix,
            )
        person.pseudonym.save!
      end
      
      # Create the address, email & phone
      if !pendingPerson.addressNil?
        postal = person.postal_addresses.new(
            :line1 => pendingPerson.line1, 
            :line2 => pendingPerson.line2, 
            :line3 => pendingPerson.line3, 
            :city => pendingPerson.city, 
            :state => pendingPerson.state, 
            :postcode => pendingPerson.postcode, 
            :country => pendingPerson.country, 
            :isdefault => true
          );
        person.save!
      end
      
      if !pendingPerson.emailNil?
        postal = person.email_addresses.new(
            :email => pendingPerson.email,
            :isdefault => true
          );
        person.save!
      end
      
      if !pendingPerson.phoneNil?
        postal = person.phone_numbers.new(
            :number => pendingPerson.phone, 
            :phone_type_id => PhoneTypes['Home'] # Assumption!!!
          );
        person.save!
      end
    end

#
#
#

@@UPDATE_IMPORT_STATES_NAME = <<"EOS"
  update pending_import_people pip,(
    select pending_import_people.id, pending_import_people.datasource_id, pending_import_people.datasource_dbid,
    count(people.id) matches, peoplesources.datasource_id people_did, peoplesources.datasource_dbid people_dbid
    from pending_import_people
    left outer join people
    on pending_import_people.first_name = people.first_name 
    and pending_import_people.last_name = people.last_name
    left join peoplesources on peoplesources.person_id = people.id
    group by pending_import_people.id, people.id
  ) cand
  set pendingtype_id = case
      when (cand.matches = 1 AND cand.datasource_id = cand.people_did AND cand.datasource_dbid = cand.people_dbid ) then 
EOS

@@UPDATE_IMPORT_STATES_NAME2 = <<"EOS"    
      when (cand.matches = 1 AND (cand.datasource_id != cand.people_did OR cand.datasource_dbid != cand.people_dbid) ) then 
EOS


@@UPDATE_IMPORT_STATES_NAME3 = <<"EOS"    
      when (cand.matches > 1) then
EOS

@@UPDATE_IMPORT_STATES_NAME4 = <<"EOS"    
    end
  where pip.id = cand.id
EOS

# Afer the above AND the following - -1 == update
# After the following - null == insert
@@UPDATE_IMPORT_STATES_DBID = <<"EOS"
  update pending_import_people pip,(
    select pending_import_people.id, count(peoplesources.id) matches, 
    people.first_name, people.last_name, 
    pending_import_people.first_name import_first_name, pending_import_people.last_name import_last_name
    from pending_import_people
    left join peoplesources on peoplesources.datasource_id = pending_import_people.datasource_id
    AND peoplesources.datasource_dbid = pending_import_people.datasource_dbid
    left join people on people.id = peoplesources.person_id
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
