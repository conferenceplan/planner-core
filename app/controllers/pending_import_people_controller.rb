class PendingImportPeopleController < ApplicationController
  require 'csv'
  before_filter :require_user

  def index
    @pendingImportPeople = PendingImportPerson.find :all
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
     @parsed_file=CSV::Reader.parse(params[:dump][:file])
     n=0
     @parsed_file.shift
     @testImport = false
     if (params[:dump][:importtype] == "renotest")
       @testImport = true
     elsif (params[:dump][:importtype] != "reno")
        redirect_to :action => 'index'
     end
     
     @parsed_file.each  do |row|  
       if (@testImport)
          pendingImportPerson = PendingImportPerson.new(:first_name => row[2],
                                                     :last_name => row[3],
                                                     :registration_number => row[0],
                                                     :registration_type => row[1])
       else
          pendingImportPerson = PendingImportPerson.new(:first_name => row[2],
                                                     :last_name => row[3],
                                                     :line1 => row[4],
                                                     :line2 => row[5],
                                                     :city => row[6],
                                                     :postcode => row[7],
                                                     :state => row[8],
                                                     :country => row[9],
                                                     :phone => row[10],
                                                     :registration_number => row[0],
                                                     :registration_type => row[1],
                                                     :email => row[11])
       end
        pendingImportPerson.save

       newPersonFlag = true
       savePersonAsPending = false
       nReg = nil
       if (pendingImportPerson.registration_number)
          nReg = RegistrationDetail.find_or_initialize_by_registration_number(pendingImportPerson.registration_number)
          newPersonFlag = nReg.new_record?
       end
      
       if (newPersonFlag)
         # search for people with same name
         @matchpeople = Person.find_all_by_last_name_and_first_name(pendingImportPerson.last_name,pendingImportPerson.last_name)

         if (@matchpeople.length != 0)
             if (pendingImportPerson.addressNil? && pendingImportPerson.emailNil? && @testImport == true)
               newPersonFlag == false
             else               
                # check if address is the same
                @matchpeople.each do |matchperson|
                   @matchperson.postal_addresses.each do |matchaddress|
                     if (pendingImportPerson.addressMatch?(matchaddres))
                         newPersonFlag = false
                     end
                   end
                end
             
                if (newPersonFlag)
                  @matchpeople.each do |matchperson|
                     @matchperson.email_addresses.each do |matchaddress|
                       if (pendingImportPerson.email == matchaddress.email)
                         newPersonFlag = false
                       end #if
                     end #@matchaddress
                  end #@matchpeople
                end #newPeopleFlag
              
                # we found a name match, but the address did not match,
                # so we should just save it as pending
               if (newPersonFlag)
                  savePersonAsPending = true
                  newPersonFlag = false
               end
            end
         end
       end
       
 
       if (newPersonFlag)
           inviteStatus = InviteStatus.find_by_name("Not Invited")
           p=Person.new(:first_name => pendingImportPerson.first_name,
                        :last_name => pendingImportPerson.last_name,
                        :invitestatus_id=> inviteStatus.id)
           if (pendingImportPerson.registration_number)
              nReg.registration_type = pendingImportPerson.registration_type
              p.registrationDetail = nReg
           end
           
           p.save
           if (@testImport == false)
              @a=p.postal_addresses.new(:line1 => pendingImportPerson.line1,
                                        :line2 => pendingImportPerson.line2,
                                        :city  => pendingImportPerson.city,
                                        :postcode => pendingImportPerson.postcode,
                                        :state => pendingImportPerson.state,
                                        :country => pendingImportPerson.country,
                                        :phone => pendingImportPerson.phone)    
              @e=p.email_addresses.new(:email => pendingImportPerson.email)
            end
            if (p.save)
                 pendingImportPerson.destroy
                 n=n+1
                 GC.start if n%50==0
            end
            flash.now[:message]="CSV Import Successful,  #{n} new
                                records added to data base"
       else
         if (!savePersonAsPending)
           if (nReg != nil)
            # found record already, update if update fails (because we
            # can't figure out what to update due to multiple addresses)
            # save pending person for later updating
            person = Person.find_by_id_and_last_name_and_first_name(nReg.person_id,pendingImportPerson.last_name,pendingImportPerson.first_name)
            if (person)
              if (@testImport == true)
                pendingImportPerson.destroy
              else
                if (person.UpdateIfPendingPersonDifferent(pendingImportPerson.id))
                  pendingImportPerson.destroy
                end #update
              end #testimport
             end #person (we did not find a name and id match, so we probably have a bad id)
         else 
           pendingImportPerson.destroy
         end #reg nil
       end #save person as pending
      end #newperson
     end #do
     redirect_to :action => 'index'
 end
end
