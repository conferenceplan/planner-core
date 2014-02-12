class PlannerMailer < ActionMailer::Base
  default from: "from@example.com"
  
  def send_email(args)
    mail args
  end
  
end
