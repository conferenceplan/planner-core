class PendingImportPerson < ActiveRecord::Base
  def addressNil?
    if ((pendingImportPerson.line1 == nil || pendingImportPerson.line1 == "") &&
        (pendingImportPerson.line2 == nil || pendingImportPerson.line2 == "") &&
        (pendingImportPerson.line3 == nil || pendingImportPerson.line3 == "") && 
        (pendingImportPerson.city == nil || pendingImportPerson.city == "") &&
        (pendingImportPerson.state == nil || pendingImportPerson.state == "") &&
        (pendingImportPerson.postcode == nil || pendingImportPerson.postcode == "") &&
        (pendingImportPerson.country == nil || pendingImportPerson.country == ""))
        return true
    else
      return false
    end                   
  end
  
  def emailNil?
    if (pendingImportPerson.email == nil || pendingImportPerson.email == "")
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
