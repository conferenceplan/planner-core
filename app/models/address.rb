class Address < ActiveRecord::Base
  attr_accessible :lock_version, :isvalid, :addressable_id, :addressable_type, :person_id, :addressable, :venue_id
  
  belongs_to :person
  belongs_to :addressable, :polymorphic => :true
  
  audited :associated_with => :person


  after_save :check_default

  def check_default
    if addressable.is_a?(PostalAddress) || addressable.is_a?(EmailAddress)
      if addressable.isdefault
        if addressable.is_a?(PostalAddress)
          PostalAddress.joins(:addresses).where(['addresses.person_id = ? && postal_addresses.id != ?', person.id, addressable.id]).update_all("postal_addresses.isdefault = 0")
        end
        if addressable.is_a?(EmailAddress)
          EmailAddress.joins(:addresses).where(['addresses.person_id = ? && email_addresses.id != ?', person.id, addressable.id]).update_all("email_addresses.isdefault = 0")
        end
      end
    end
  end

end
