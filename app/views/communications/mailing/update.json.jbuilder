
json.array! @mailings do |mailing|

    json.partial! 'mailing', mailing: mailing

end
