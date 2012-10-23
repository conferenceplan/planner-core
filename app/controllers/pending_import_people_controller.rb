class PendingImportPeopleController < PlannerController
  require 'csv'

  def index
    @pendingImportPeople = PendingImportPerson.find :all, :order => :last_name
  end
  
  def show
    @pendingImportPerson = PendingImportPerson.find(params[:id])
  end
  
  def create
    @pendingImportPerson = PendingImportPerson.new(params[:pending_import_person])
    if (@pendingImportPerson.save)
       redirect_to :action => 'show', :id => @pendingImportPerson
    else
      render :action => 'new'
    end 
  end
  def new
    @pendingImportPerson = PendingImportPerson.new
  end
  
  def edit
    @pendingImportPerson = PendingImportPerson.find(params[:id])
  end
  
  def update
    @pendingImportPerson = PendingImportPerson.find(params[:id])
    if @pendingImportPerson.update_attributes(params[:pending_import_person])
      redirect_to :action => 'show', :id => @pendingImportPerson
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @pendingImportPerson = PendingImportPerson.find(params[:id])
    @pendingImportPerson.destroy
    redirect_to :action => 'index'
  end
  
  def import
    
  end
  
  def doimport
     parsed_file=CSV::Reader.parse(params[:dump][:file])
     n=0
     parsed_file.shift
     testImport = false
     master = false
     
     inDatasourceId = params[:dump][:datasource_id]
     inds = Datasource.find(inDatasourceId)
     
     addressUpdateFlag = params[:dump][:addressupdate]
     nameUpdateFlag = params[:dump][:nameupdate]
  
     parsed_file.each  do |row|
        npendingImportPerson = PendingImportPerson.find_by_datasource_id_and_datasource_dbid(inDatasourceId,row[0])
        if (npendingImportPerson == nil)     
             npendingImportPerson = PendingImportPerson.new(:first_name => row[3],
                                                           :last_name => row[4],
                                                           :suffix => row[5],
                                                           :line1 => row[6],
                                                           :line2 => row[7],
                                                           :city => row[8],
                                                           :postcode => row[9],
                                                           :state => row[10],
                                                           :country => row[11],
                                                           :phone => row[12],
                                                           :datasource_dbid => row[0],
                                                           :registration_number => row[1],
                                                           :registration_type => row[2],
                                                           :email => row[13],
                                                           :alt_email => row[14],
                                                           :datasource_id => inDatasourceId)
       
            # skip to next record if name is empty - master puts empty name for duplicate records, which
            # we don't care about since are not tracking the old database dups
            next if ((npendingImportPerson.first_name == nil || npendingImportPerson.first_name == "") && (npendingImportPerson.last_name == nil || npendingImportPerson.last_name == ""))
        else
            npendingImportPerson.first_name = row[3]
            npendingImportPerson.last_name = row[4]
            npendingImportPerson.suffix = row[5]
            npendingImportPerson.line1 = row[6]
            npendingImportPerson.line2 = row[7]
            npendingImportPerson.city = row[8]
            npendingImportPerson.postcode = row[9]
            npendingImportPerson.state = row[10]
            npendingImportPerson.country = row[11]
            npendingImportPerson.phone = row[12]
            npendingImportPerson.registration_number = row[1]
            npendingImportPerson.registration_type = row[2]
            npendingImportPerson.email = row[13]
            npendingImportPerson.alt_email = row[14]
            
        end
        # this is a hack - when we save the data to the pending database, it gets modified
        # to match our constraints will nil or empty strings (this messes up our comparisons if we don't do this)
        #. We then retrieve it and use that
        # data to compare to our real database
        if (npendingImportPerson.first_name == nil)
           npendingImportPerson.first_name = ""
        end
        if (npendingImportPerson.last_name == nil)
           npendingImportPerson.last_name = ""
        end
        if (npendingImportPerson.suffix == nil)
           npendingImportPerson.suffix = ""
        end
        if (npendingImportPerson.line2 == nil)
          npendingImportPerson.line2 = ""
        end
        if (npendingImportPerson.line3 == nil)
          npendingImportPerson.line3 = ""
        end
        
        # we don't want to process the registration if it is not the priamry datasource
        # (our conference registration)
        if (inds.primary == false)
          npendingImportPerson.registration_number = nil
        end
        npendingImportPerson.save
                
        pendingImportPerson = PendingImportPerson.find(npendingImportPerson.id)
        nReg = nil
        foundReg = false
        if (inds.primary == true)
           # look for matching registration
           if (pendingImportPerson.registration_number && (pendingImportPerson.registration_number != ""))
              nReg = RegistrationDetail.find_or_initialize_by_registration_number(pendingImportPerson.registration_number)
              if (nReg.new_record? == false)
                 foundReg = true
              end
           end
        end
   
        newPersonFlag = true
        savePersonAsPending = false
        realMatchPerson = nil

        matchPeople = Person.find(:all,:include => [:peoplesource], :conditions => ["peoplesources.datasource_id = ? AND peoplesources.datasource_dbid = ?",inDatasourceId, row[0]])
        if (matchPeople.length() != 0)
          newPersonFlag = false
          if (matchPeople.length() == 1)
            realMatchPerson = matchPeople[0]
          end
        end
       
       if ((inds.primary == true) && (newPersonFlag == true))
          
          # if we find a matching registration record and this is the primary data source
          # but we did not find a person match for this data source, whcih either means
          # there is duplicate registration number somewhere (bad) or someone entered it
          # by hand and not through the import. If the name matches, we should update the registration
          if (foundReg == true)
             matchPeople = Person.find(:all,:include => [:registrationDetail],:conditions => ["last_name = ? AND first_name = ? AND suffix = ? and registration_details.registration_number = ?", pendingImportPerson.last_name, pendingImportPerson.first_name,pendingImportPerson.suffix, pendingImportPerson.registration_number])        
             if (matchPeople.length() == 0)
               # name did not match, we need to save as pending, registration problem
               savePersonAsPending = true
               newPersonFlag = false
               pendingImportPerson.pendingtype = PendingType.find_by_name("RegistrationInUse")
             else
               # we already have this person, just need to update
               newPersonFlag = false
               realMatchPerson = matchPeople[0]
             end
          end
       end
       
       
       # Figure stuff out

       if (newPersonFlag)
         # search for people with same name
         matchPeople = Person.find(:all,:include => [:peoplesource],:conditions => ["last_name = ? AND first_name = ? AND suffix = ? and (peoplesources.id IS NULL or peoplesources.datasource_id != ?)", pendingImportPerson.last_name, pendingImportPerson.first_name,pendingImportPerson.suffix, inDatasourceId])        

         # check for address and name match - if either the postal or email
         # matches, it is a match
         if (matchPeople.length() != 0)
            addressSame = false
            # check if address is the same
            matchPeople.each do |matchperson|
              matchperson.postal_addresses.each do |matchaddress|
                if (pendingImportPerson.addressMatch?(matchaddress))
                    addressSame = true
                    realMatchPerson = matchperson
                end
              end
            end
            
            # check for matching email                
            if (addressSame == true)
               addressSame = false
               matchPeople.each do |matchperson|
                 matchperson.email_addresses.each do |matcheaddress|
                   if (pendingImportPerson.email == matcheaddress.email)
                     addressSame = true
                     realMatchPerson = matchperson
                   end #if
                 end #each person
               end #each address
            end #addressSame
                
            # we found a name match, but the address did not match,
            # so we should just save it as pending, since we are not sure it is the
            # same person (people have the same names)
            if (addressSame == false)                
               savePersonAsPending = true
               pendingImportPerson.pendingtype = PendingType.find_by_name("PossibleMatchExisting")
               newPersonFlag = false
            else
              # name and address match, so go ahead and update
              newPersonFlag = false
              savePersonAsPending = false
            end
         end
       end
       
       if (newPersonFlag)
           inviteStatus = InviteStatus.find_by_name("Not Set")
           acceptanceStatus = AcceptanceStatus.find_by_name("Unknown")
           p=Person.new(:first_name => pendingImportPerson.first_name,
                        :last_name => pendingImportPerson.last_name,
                        :suffix => pendingImportPerson.suffix,
                        :invitestatus_id=> inviteStatus.id,
                        :acceptance_status_id => acceptanceStatus.id,
                        :mailing_number => 0)
                        
           if (nReg != nil)
              nReg.registration_type = pendingImportPerson.registration_type
              p.registrationDetail = nReg
           end
          
           
           p.save
           if (pendingImportPerson.addressNil? == false)
                a=p.postal_addresses.new( :line1 => pendingImportPerson.line1,
                                          :line2 => pendingImportPerson.line2,
                                          :line3 => pendingImportPerson.line3,
                                          :city  => pendingImportPerson.city,
                                          :postcode => pendingImportPerson.postcode,
                                          :state => pendingImportPerson.state,
                                          :country => pendingImportPerson.country,
                                          :isdefault => true)
           end
                                        
           if (pendingImportPerson.emailNil? == false)
               e=p.email_addresses.new(:email => pendingImportPerson.email,
                                         :isdefault => true)
           end
           if (pendingImportPerson.alt_emailNil? != nil)
               e=p.email_addresses.new(:email => pendingImportPerson.alt_email,
                                       :isdefault => false)
           end
           
           if (pendingImportPerson.phoneNil? == false)
               defaultType = PhoneTypes.find_by_name("Home")
               e=p.phone_numbers.new(:number => pendingImportPerson.phone,
                                     :phone_type_id => defaultType.id)
           end
         
           if (p.save)
                 xp = Peoplesource.find_by_person_id(p.id)
                 xp.datasource_dbid = row[0]
                 xp.save
                 pendingImportPerson.destroy
                 n=n+1
                 GC.start if n%50==0
           end
           flash.now[:message]="CSV Import Successful,  #{n} new
                                records added to data base"
       else
         if (!savePersonAsPending)
            if (inds.primary == true && ((realMatchPerson.datasource == nil) || (realMatchPerson.datasource.primary == false)))
                realMatchPerson.datasource = inds
                realMatchPerson.save
            end
             # we are updating, if registration not in database, pass in one to update
             newRegistrationDetail = nil
             if (foundReg == true)
               if ((realMatchPerson.registrationDetail != nil) && (realMatchPerson.registrationDetail.registration_number != nReg.registration_number))
                 pendingImportPerson.pendingtype = PendingType.find_by_name("RegistrationInUse")
                 pendingImportPerson.save
                 savePersonAsPending = true
               end
             end
             if (!savePersonAsPending)
                if (nReg != nil)
                 nReg.registration_type = pendingImportPerson.registration_type
                 newRegistrationDetail = nReg
              
                end  
               # found record already, update if update fails (because we
               # can't figure out what to update due to multiple addresses) 
      
               savePendingStatus = realMatchPerson.UpdateIfPendingPersonDifferent(pendingImportPerson.id,addressUpdateFlag,nameUpdateFlag,newRegistrationDetail)
               if (savePendingStatus == nil)
                pendingImportPerson.destroy
               else
                  pendingImportPerson.pendingtype = savePendingStatus
                  pendingImportPerson.save
               end #update   
             end #registration check
         else
           pendingImportPerson.save
         end #save person as pending
       end #newperson
     end #do
     redirect_to :action => 'index'
 end
end
