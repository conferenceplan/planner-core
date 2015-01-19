class MailTemplate < ActiveRecord::Base
  attr_accessible :lock_version, :title, :subject, :content, :mail_use_id, :survey_id, :transiton_invite_status_id
  
  has_enumerated :mail_use, :class_name => 'MailUse'
  has_enumerated :transiton_invite_status, :class_name => 'InviteStatus' # the status that a person transistions too after the mail is sent out
  
  belongs_to :survey
  has_many :mailings

  before_destroy :check_for_mailings

  def as_json(options={})
    res = super()

    res['mail_use'] = mail_use.name  
        
    return res
  end

private

  # we  want to check that this has not been used by a mailing
  def check_for_mailings
    if mailings.any?
      # errors.add :base, "Sorry, you can't delete a template that's being used in a mailing."
      raise "Sorry, you can't delete a template that's being used in a mailing."
    end
  end

end
