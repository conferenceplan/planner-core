class Surveys::QuestionListCell < Cell::Rails

  def display
    render
  end

  def javascript(args)
    @start_date = SiteConfig.first
    render
  end

  def templates
    render
  end

end
