# Methods added to this helper will be available to all templates in the application.

module ApplicationHelper
  def menu()
    menu = Menu.find_by_title("Main")
    render :partial => 'menus/index', :locals => {:menu => menu}
  end
end

