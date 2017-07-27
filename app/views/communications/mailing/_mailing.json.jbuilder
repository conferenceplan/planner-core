
json.id                 mailing.id
json.lock_version       mailing.lock_version
json.mailing_number     mailing.mailing_number # TODO - change number to id
json.mail_template_id   mailing.mail_template_id
json.mail_template      mailing.mail_template ? mailing.mail_template.title : ''
json.mail_use           mailing.mail_template ? mailing.mail_template.mail_use.name : ''
json.scheduled          mailing.scheduled
json.testrun            mailing.testrun
json.include_email      mailing.include_email
json.cc_all             mailing.cc_all

json.template           mailing.mail_template
json.date_sent          mailing.date_sent
