class PendingImportPerson < ActiveRecord::Base
  attr_accessible :lock_version, :first_name, :last_name, :suffix, :prefix, :line1, :line2, :line3, :city, :state, :postcode, :country,
                  :phone, :email, :registration_number, :registration_type, :datasource_id, :datasource_dbid, :pendingtype_id, :alt_email,
                  :pub_first_name, :pub_last_name, :pub_suffix, :pub_prefix,
                  :bio, :invite_status, :invite_category, :accept_status
  
  has_enumerated :pendingtype, :class_name => 'PendingType'
  belongs_to :datasource
  
  def addressNil?
    (self.line1 == nil || self.line1 == "") &&
      (self.line2 == nil || self.line2 == "") &&
      (self.line3 == nil || self.line3 == "") && 
      (self.city == nil || self.city == "") &&
      (self.state == nil || self.state == "") &&
      (self.postcode == nil || self.postcode == "") &&
      (self.country == nil || self.country == "")
  end
  
  def emailNil?
    (self.email == nil || self.email == "")
  end
  
  def alt_emailNil?
    (self.alt_email == nil || self.alt_email == "")
  end
  
  def phoneNil?
    (self.phone == nil || self.phone == "")
  end

  def pseudonymNil?
    (self.pub_first_name == nil || self.pub_first_name == "") &&
    (self.pub_last_name == nil || self.pub_last_name == "") &&
    (self.suffix == nil || self.suffix == "")
  end
  
  def addressMatch?(matchaddress)
    (self.line1 == matchaddress.line1) &&
      (self.line2 == matchaddress.line2) &&
      (self.line3 == matchaddress.line3) &&
      (self.city == matchaddress.city) &&
      (self.state == matchaddress.state) &&
      (self.postcode == matchaddress.postcode) &&
      (self.country == matchaddress.country)
  end
end
