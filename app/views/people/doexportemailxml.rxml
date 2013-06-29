xml.people do
  @people.each do |p|
    xml.person do
      name = p.getFullName()
      xml.name(name)
      p.email_addresses.each do |email_address|
        if (email_address.isdefault == true)
          xml.address(email_address.email)
        end
      end
      if p.survey_respondent
        xml.key(p.survey_respondent.key)
      else
        xml.key(NO KEY)
      end
    end
  end
end
