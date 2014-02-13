class PlannerMailer < ActionMailer::Base
  
  def send_email(args)
    mail args
  end
  
end
