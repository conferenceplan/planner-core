class Reports::ManageCell < Cell::Rails

  def display
    @extra_reports_display = [] if ! @extra_reports_display
    render
  end

  def javascript
    @extra_javascript = [] if ! @extra_javascript
    render
  end

  def templates
    @extra_template = [] if !@extra_template
    render
  end

end
