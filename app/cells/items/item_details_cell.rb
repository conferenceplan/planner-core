class Items::ItemDetailsCell < Cell::Rails

  def templates
    @extra_template = [] if !@extra_template
    @extra_tab_template = [] if !@extra_tab_template
    render
  end

  def javascript
    @extra_javascript = [] if ! @extra_javascript
    @cfg = SiteConfig.first
    render
  end

  def display
    @extra_tab_display = [] if ! @extra_tab_display
    @extra_tab_post_participants_display = [] if ! @extra_tab_post_participants_display
    render
  end

end
