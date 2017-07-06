class PhoneNumber < ActiveRecord::Base
  attr_accessible :lock_version, :number, :phone_type_id, :isdefault, :label
  
  audited :allow_mass_assignment => true

  has_many :addresses, :as => :addressable
  has_many :people, :through => :addresses,
            :source => :addressable,
            :source_type => 'PhoneNumber'
  
  has_enumerated :phone_type, :class_name => 'PhoneTypes'

  after_create :check_for_type
  after_save  :check_default

  private
  
  def check_for_type
    if !phone_type_id
      update_attributes(:phone_type_id => PhoneTypes['Work'].id)
    end
  end

  def check_default
    if self.isdefault # if this is the default then make the others non default (for the person)
      self.addresses.each do |address|
        PhoneNumber.joins(:addresses).where(['addresses.person_id = ? && phone_numbers.id != ?', address.person_id, self.id]).update_all("phone_numbers.isdefault = 0")
      end
    end
  end

end
