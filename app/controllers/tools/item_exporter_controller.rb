class Tools::ItemExporterController < PlannerController
  def export
    
    @items = ProgramItemsService.findAllItems

    # output as an Excel file
    response.headers['Content-Disposition'] = 'attachment; filename="items_' + Time.now.strftime("%m-%d-%Y") + '.xlsx"'
  end
end
