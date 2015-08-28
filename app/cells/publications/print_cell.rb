class Publications::PrintCell < Cell::Rails

  def display
    render
  end

  def javascript
    @extra_javascript = [] if ! @extra_javascript
    @start_date = SiteConfig.first
    render
  end

  def templates
    render
  end

end
