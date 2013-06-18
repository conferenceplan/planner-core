class Mailing < ActiveRecord::Base
  has_many  :person_mailing_assignments
  has_many  :people, :through => :person_mailing_assignments
  
  belongs_to :mail_template
  
  validate :number_and_mail_use_unique
  
  def as_json(options={})
    res = super()

    res['mail_use'] = mail_template.mail_use.name  
        
    return res
  end

  
  def number_and_mail_use_unique
    # Make sure that the combination of number and mail_use_id is unique
    m = Mailing.first :conditions => ["mailing_number = ? AND mail_templates.mail_use_id = ?", mailing_number, mail_template.mail_use_id], :joins => :mail_template
    errors.add(:mailing_number, "Mailing number and mail usage must be unique") if m != nil && m.id != id
  end
end
