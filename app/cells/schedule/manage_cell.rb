require "browser"

class Schedule::ManageCell < Cell::Rails

  def display
    @browser = Browser.new(
        accept_language: request.headers["Accept-Language"],
        ua: request.headers["User-Agent"]
      )
    render
  end
  
  def javascript
    @start_date = SiteConfig.first
    render
  end

  def templates
    @start_date = SiteConfig.first
    render
  end

end
