class TopMenuCell < Cell::Rails

  # Based on the URL get the menu and submenu position
  # search the menu structure for request.fullpath
  def display(args)
    @topmenu = args[:menu]
    
    @active_top_menu = @active_sub_menu = @submenu = subidx = nil
    
    path = request.fullpath
    if path.include? baseUri
      path = path.slice(baseUri.length(), path.length())
    end
    # remove the baseUri if present
    
    idx = @topmenu.find_index{|item| 
      found = item[:target].eql? path
      if item[:sub_menu] # && !found
        subidx = item[:sub_menu].find_index{|i| i[:target].eql? path }
      end
      found || (subidx != nil)
    }
    
    @active_top_menu = @topmenu[idx][:title] if idx
    @active_sub_menu = @topmenu[idx][:sub_menu][subidx][:title] if subidx && idx
    @submenu = @topmenu[idx][:sub_menu] if idx
    
    render
  end

end
