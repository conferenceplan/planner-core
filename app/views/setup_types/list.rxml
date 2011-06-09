xml.rows do
  xml.page(@page)
  xml.total(@nbr_pages)
  xml.records(@count)
  @setup_types.each do |type|
    xml.row({:id => type.id}) do
      xml.cell(type.name)
      xml.cell(type.description)
    end
  end
end
