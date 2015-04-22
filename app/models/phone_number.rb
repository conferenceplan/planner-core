class PhoneNumber < ActiveRecord::Base
  attr_accessible :lock_version, :number, :phone_type_id
  
  audited :allow_mass_assignment => true

  has_many :addresses, :as => :addressable
  has_many :people, :through => :addresses,
            :source => :addressable,
            :source_type => 'PhoneNumber'
  
  has_enumerated :phone_type, :class_name => 'PhoneTypes'

  after_create :check_for_type

  private
  
  def check_for_type
    if !phone_type_id
      update_attributes(:phone_type_id => PhoneTypes['Work'].id)
    end
  end

end
