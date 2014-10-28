class Admin::ConfigsCell < Cell::Rails
  
  def display
    render
  end

  def javascript
    @start_date = SiteConfig.first
    render
  end

  def templates
    render
  end

end
