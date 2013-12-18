
json.array!(@mail_templates) do |json, mail_template|

    json.partial! 'mail_template', mail_template: mail_template 

end
