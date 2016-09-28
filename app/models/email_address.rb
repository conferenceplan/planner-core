class EmailAddress < ActiveRecord::Base
  attr_accessible :lock_version, :isdefault, :email, :label
  audited :allow_mass_assignment => true

  has_many :addresses, as: :addressable
  has_many :people, through: :addresses

  before_save :clean_email
  after_save  :check_default

  def clean_email
    self.email.strip!
  end

  def check_default
    if self.isdefault # if this is the default then make the others non default (for the person)
      self.addresses.each do |address|
        EmailAddress.joins(:addresses).where(['addresses.person_id = ? && email_addresses.id != ?', address.person_id, self.id]).update_all("email_addresses.isdefault = 0")
      end
    end
  end

end
