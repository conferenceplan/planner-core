class PendingImportPerson < ActiveRecord::Base
  attr_accessible :lock_version, :first_name, :last_name, :suffix, :line1, :line2, :line3, :city, :state, :postcode, :country,
                  :phone, :email, :registration_number, :registration_type, :datasource_id, :datasource_dbid, :pendingtype_id, :alt_email
                  # TODO - need publication name
  
  has_enumerated :pendingtype, :class_name => 'PendingType'
  belongs_to :datasource
  
  def addressNil?
    if ((self.line1 == nil || self.line1 == "") &&
        (self.line2 == nil || self.line2 == "") &&
        (self.line3 == nil || self.line3 == "") && 
        (self.city == nil || self.city == "") &&
        (self.state == nil || self.state == "") &&
        (self.postcode == nil || self.postcode == "") &&
        (self.country == nil || self.country == ""))
        return true
    else
      return false
    end                   
  end
  
  def emailNil?
    if (self.email == nil || self.email == "")
      return true
    else
      return false
    end
  end
  
  def alt_emailNil?
    if (self.alt_email == nil || self.alt_email == "")
      return true
    else
      return false
    end
  end
  
  def phoneNil?
     if (self.phone == nil || self.phone == "")
      return true
    else
      return false
    end
  end
  
  def addressMatch?(matchaddress)
     if ((self.line1 == matchaddress.line1) &&
        (self.line2 == matchaddress.line2) &&
        (self.line3 == matchaddress.line3) &&
         (self.city == matchaddress.city) &&
         (self.state == matchaddress.state) &&
         (self.postcode == matchaddress.postcode) &&
         (self.country == matchaddress.country))
         return true
      else
        return false
      end
  end
end
