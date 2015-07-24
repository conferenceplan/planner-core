class PlannerMailer < ActionMailer::Base
  
  def send_email(args, content = nil)
    message = mail args
    message
  end

end
