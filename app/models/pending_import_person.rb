class PendingImportPerson < ActiveRecord::Base
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
  def addressMatch?(matchaddress)
     if ((self.line1 == matchaddress.line1)
        (self.line2 == matchaddress.line2)
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
