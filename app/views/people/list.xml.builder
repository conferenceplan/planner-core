xml.rows do
  xml.page(@page)
  xml.total(@nbr_pages)
  xml.records(@count)
  @people.each do |person|
    xml.row({:id => person.id}) do
      xml.cell(person.first_name)
      xml.cell(person.last_name)
      xml.cell(person.suffix)
      # For precis view we do not need the following 
      xml.cell(person.mailing_number)
      person.invitestatus ? xml.cell(person.invitestatus.name) : xml.cell("")
      person.invitation_category ? xml.cell(person.invitation_category.name) : xml.cell("")
      person.acceptance_status ? xml.cell(person.acceptance_status.name) : xml.cell("")
      SurveyService.personAnsweredSurvey( person, 'partsurvey') ? xml.cell("Y") : xml.cell("N")
      #
      if person.pseudonym
        person.pseudonym.first_name ? xml.cell(person.pseudonym.first_name) : xml.cell("")
        person.pseudonym.last_name ? xml.cell(person.pseudonym.last_name) : xml.cell("")
        person.pseudonym.suffix ? xml.cell(person.pseudonym.suffix) : xml.cell("")
      else      
        xml.cell("")
        xml.cell("")
        xml.cell("")
      end
      if (person.survey_respondent)
        xml.cell(person.survey_respondent.id)
      else
        xml.cell("0")
      end
      #
      xml.cell(person.lock_version)
    end
  end
end

