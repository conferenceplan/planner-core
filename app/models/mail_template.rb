class MailTemplate < ActiveRecord::Base
  has_enumerated :mail_use, :class_name => 'MailUse'
  
  belongs_to :survey
end
