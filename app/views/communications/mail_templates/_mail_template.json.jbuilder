
json.id                 mail_template.id
json.mail_use_id        mail_template.mail_use_id
json.mail_use_name      (mail_template.mail_use ? mail_template.mail_use.name : '')
json.title              mail_template.title
json.subject            mail_template.subject
json.content            mail_template.content
json.survey_id          (mail_template.survey ? mail_template.survey_id : nil)
json.survey             (mail_template.survey ? mail_template.survey.name : nil)
json.transiton_invite_status_id     mail_template.transiton_invite_status_id
json.transiton_invite_status_name   (mail_template.transiton_invite_status ? mail_template.transiton_invite_status.name : '')
json.lock_version       mail_template.lock_version
