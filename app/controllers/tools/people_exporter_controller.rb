class Tools::PeopleExporterController < PlannerController
  
  def export
    invitestatus_id = params[:invitestatus_id].to_i > 0 ? params[:invitestatus_id].to_i : nil
    invitation_category_id = params[:invitation_category_id].to_i > 0 ? params[:invitation_category_id].to_i : nil

    # Get the people (batch), filter by invite status and category
    @people = PeopleService.findAllPeople invitestatus_id, invitation_category_id
  
    # output as an Excel file - TODO
    response.headers['Content-Disposition'] = 'attachment; filename="people_' + Time.now.strftime("%m-%d-%Y") + '.xlsx"'
  end
  
end
