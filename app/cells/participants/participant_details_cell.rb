class Participants::ParticipantDetailsCell < Cell::Rails

  def display
    @extra_items_display = [] if ! @extra_items_display
    @extra_items_tab_display = [] if ! @extra_items_tab_display
    @extra_tab_display = [] if ! @extra_tab_display
    render
  end
  
  def javascript
    @extra_javascript = [] if ! @extra_javascript
    @start_date = SiteConfig.first
    render
  end
  
  def templates
    @extra_template = [] if !@extra_template
    @extra_tab_template = [] if !@extra_tab_template
    render
  end

end
