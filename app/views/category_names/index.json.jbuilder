
json.total @total

json.rows @category_names do |category_name|

    json.partial! 'category_name', category_name: category_name 

end
