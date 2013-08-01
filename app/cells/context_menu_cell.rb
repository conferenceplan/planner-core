class ContextMenuCell < Cell::Rails

  def display(args)
    @menu = args[:menu]
    
    render
  end

end
