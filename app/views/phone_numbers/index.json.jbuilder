
json.array!(@phoneNumbers) do |json, phone|

    json.partial! 'phone', phone: phone 

end
