
json.id                 venue.id
json.name               venue.name
json.sort_order         venue.sort_order
json.lock_version       venue.lock_version
if venue.postal_address
    json.postal_address do
        json.lock_version    venue.postal_address.lock_version
        json.line1           venue.postal_address.line1
        json.line2           venue.postal_address.line2
        json.line3           venue.postal_address.line3
        json.city            venue.postal_address.city
        json.state           venue.postal_address.state
        json.postcode        venue.postal_address.postcode
        json.country         venue.postal_address.country
        json.isdefault       venue.postal_address.isdefault
        json.latitude        venue.postal_address.latitude
        json.longitude       venue.postal_address.longitude
    end
end
    