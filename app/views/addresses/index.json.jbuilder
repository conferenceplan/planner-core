
json.array!(@postalAddresses) do |json, address|
    json.id address.id
    json.line1 address.line1
    json.line2 address.line2
    json.line3 address.line3
    json.city address.city
    json.state address.state
    json.postcode address.postcode
    json.country address.country
    json.isdefault address.isdefault
    json.lock_version address.lock_version
end
