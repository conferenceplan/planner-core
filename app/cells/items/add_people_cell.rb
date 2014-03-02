class Items::AddPeopleCell < Cell::Rails

  def display(args)
    @prog_item = args.has_key?(:prog_item) ? args[:prog_item] : nil
    render
  end
  
  def javascript(args)
    @prog_item = args.has_key?(:prog_item) ? args[:prog_item] : nil
    render
  end

  def templates
    render
  end

end
