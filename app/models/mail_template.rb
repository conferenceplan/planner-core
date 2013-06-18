class MailTemplate < ActiveRecord::Base
  has_enumerated :mail_use, :class_name => 'MailUse'
  
  belongs_to :survey
  has_many :mailings


  def as_json(options={})
    res = super()

    res['mail_use'] = mail_use.name  
        
    return res
  end

end
