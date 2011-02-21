xml.rows do
  xml.page(@page)
  xml.total(@nbr_pages)
  xml.records(@count)
  @respondents.each do |respondent|
    xml.row({:id => respondent.id}) do
      xml.cell(respondent.first_name)
      xml.cell(respondent.last_name)
      xml.cell(respondent.updated_at)
      xml.cell(respondent.person.id)
    end
  end
end

