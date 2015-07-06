class Participants::ManageCell < Cell::Rails

  def display
    @extra_menu_display = [] if ! @extra_menu_display
    render
  end
  
end
