
json.array! @surveys do |survey|

    json.partial! 'survey', survey: survey

end
