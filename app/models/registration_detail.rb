class RegistrationDetail < ActiveRecord::Base
  attr_accessible :lock_version, :registration_number, :registration_type, :registered, :person_id, :can_share
  
  belongs_to  :person 
  
  audited :associated_with => :person, :allow_mass_assignment => true

  def self.registered
    details = where("registration_details.registered is true")

    if ActsAsTenant.current_tenant
      details = details.where("registration_details.conference_id = ?", ActsAsTenant.current_tenant.id)
    end

    details
  end

  def self.today

    details = where([
      "registration_details.created_at >= :today_start and registration_details.created_at <= :today_end", 
      {today_start: DateTime.now.beginning_of_day, today_end: DateTime.now.end_of_day}
    ])

    if ActsAsTenant.current_tenant
      details = details.where("registration_details.conference_id = ?", ActsAsTenant.current_tenant.id)
    end

    details

  end

end
