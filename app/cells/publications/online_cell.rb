class Publications::OnlineCell < Cell::Rails

  def display
    render
  end

  def javascript
    render
  end

  def templates
    @extra_review_template = [] if !@extra_review_template
    @extra_last_pub_template = [] if !@extra_last_pub_template
    render
  end

end
