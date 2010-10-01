class Person < ActiveRecord::Base
  
  # TODO - this is probably not the correct uniqueness test
  validates_uniqueness_of :last_name,
            :scope => [:first_name], 
            :case_sensitive => false, :message => ':that person already exists in the database.' 

  has_many  :addresses
  
  has_many  :postal_addresses, :through => :addresses,
            :source => :addressable, 
            :source_type => 'PostalAddress'
  
  has_many  :email_addresses, :through => :addresses, 
            :source => :addressable, 
            :source_type => 'EmailAddress'

  accepts_nested_attributes_for :postal_addresses, :email_addresses

  has_many  :relationships
  
  has_many  :related_people, :through => :relationships,
            :source => :relatable,
            :source_type => 'Person'

  has_many  :exclusions
  
  has_many  :excluded_people, :through => :exclusions, 
            :source => :excludable,
            :source_type => 'Person'
  
  has_many  :excluded_periods, :through => :exclusions,
            :source => :excludable,
            :source_type => 'Period'
  
  has_many  :excluded_items, :through => :exclusions,
            :source => :excludable,
            :source_type => "ProgrammeItem" 
  
  # TODO - check this
  has_many  :programmeItemAssignments
  has_many  :programmeItems, :through => :programmeItemAssignments

  has_one   :registrationDetail, :dependent => :delete
  has_one   :survey_respondent
  has_enumerated :invitestatus, :class_name => 'InviteStatus'
  
  #
  acts_as_taggable
  acts_as_taggable_on :activities
  
  def removeAddress(address)
    # TODO - change to handle any address type
     postal_addresses.delete(address) # remove it from the person
     # and then make sure that it is not used by another person
     if (! addresses.find(:all, :conditions =>  ["addressable_id = ? and person_id != ?", address, @id] ) )
       address.destroy
     end
  end

  def removeAllAddresses()
    # Get the addresses and if they are not reference by other people the get rid of them...
    postalAddresses = self.postal_addresses
    
    if (postalAddresses)
      postalAddresses.each do |address|
        self.removeAddress(address)
      end
    end
  end
  
end
