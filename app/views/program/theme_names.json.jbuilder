json.cache! [request.host, request.path] do
    json.array! @theme_names
end
