
json.array!(@phoneNumbers) do |phone|

    json.partial! 'phone', phone: phone 

end
