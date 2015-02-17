class Admin::ConfigsCell < Cell::Rails
  
  def display
    @extra_system_config_menu = [] if !@extra_system_config_menu
    render
  end

  def javascript
    @extra_javascript = [] if !@extra_javascript
    @start_date = SiteConfig.first
    render
  end

  def templates
    @extra_template = [] if !@extra_template
    render
  end

end
