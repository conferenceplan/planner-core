class Items::ItemDetailsCell < Cell::Rails

  def templates
    render
  end

  def javascript
    @start_date = SiteConfig.first
    render
  end

  def display
    render
  end

end
