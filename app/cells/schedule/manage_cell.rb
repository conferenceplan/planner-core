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
    render
  end

  def templates
    render
  end

end
