class Mailing < ActiveRecord::Base
  attr_accessible :lock_version, :testrun, :scheduled, :mailing_number, :mail_template_id, :last_person_idx, :include_email, :cc_all
  
  has_many  :person_mailing_assignments, dependent: :destroy
  has_many  :people, :through => :person_mailing_assignments
  has_many  :mail_histories, dependent: :destroy
  
  belongs_to :mail_template, touch: true, dependent: :destroy
  
  validate :number_and_mail_use_unique
  
  def as_json(options={})
    res = super()

    res['mail_use'] = mail_template ? mail_template.mail_use.name : ''
        
    return res
  end

  def date_sent
    mail_histories.any? ? mail_histories.pluck(:date_sent).last : nil
  end

  
  def number_and_mail_use_unique
    # Make sure that the combination of number and mail_use_id is unique
    m = Mailing.references(:mail_template).includes(:mail_template).where(["mailing_number = ? AND mail_templates.mail_use_id = ?", mailing_number, mail_template.mail_use_id]).first
 errors.add(:mailing_number, I18n.t("planner.core.errors.unique-mailing-error")) if m != nil && m.id != id
  end

  def title
    mail_template ? mail_template.title : nil
  end

  def subject
    mail_template ? mail_template.subject : nil
  end

  def content
    mail_template ? mail_template.content : nil
  end

  def display_name
    _name = title.present? && title != subject ? "[#{title}] " : ''
    _name = _name + (subject.present? ? subject : I18n.t('planner.front.messages.emails.detail-panel.header.no-subject'))
    _name
  end

end
