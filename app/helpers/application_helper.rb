module ApplicationHelper
  def menu()
    menu = Menu.find_by_title("Main")
    render :partial => 'menus/index', :locals => {:menu => menu}
  end
end
