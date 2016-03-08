class Participants::ImportCell < Cell::Rails

  def display
    render
  end

  def javascript
    render
  end

  def templates
    render
  end

  def mapping_element(args)
    @field = args[:field]
    render
  end

end
