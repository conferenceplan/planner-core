class TopMenuCell < Cell::Rails

  # Based on the URL get the menu and submenu position
  # search the menu structure for request.fullpath
  def display(args)
    @menu = args[:menu]
    
    @active_top_menu = @active_sub_menu = @submenu = subidx = nil
    
    idx = @menu.find_index{|item| 
      found = item[:target].eql? request.fullpath
      if item[:sub_menu] # && !found
        subidx = item[:sub_menu].find_index{|i| i[:target].eql? request.fullpath }
      end
      found || (subidx != nil)
    }
    
    @active_top_menu = @menu[idx][:title] if idx
    @active_sub_menu = @menu[idx][:sub_menu][subidx][:title] if subidx && idx
    @submenu = @menu[idx][:sub_menu] if idx
    
    render
  end

end
