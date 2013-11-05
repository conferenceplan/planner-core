
json.array! @queries do |query|

    json.partial! 'query', query: query, terse: true

end
