
json.total @total

json.rows @theme_names do |theme_name|

    json.partial! 'theme_name', theme_name: theme_name 

end
