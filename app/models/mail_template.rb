class MailTemplate < ActiveRecord::Base
  attr_accessible :lock_version, :title, :subject, :content, :mail_use_id, :survey_id, :transiton_invite_status_id
  
  has_enumerated :mail_use, :class_name => 'MailUse'
  has_enumerated :transiton_invite_status, :class_name => 'InviteStatus' # the status that a person transistions too after the mail is sent out
  
  belongs_to :survey
  has_many :mailings

  def as_json(options={})
    res = super()

    res['mail_use'] = mail_use.name  
        
    return res
  end

end
