# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def menu(menuid = 1)
    menu = Menu.find(menuid)
    render :partial => 'menus/index', :locals => {:menu => menu}
  end
end
