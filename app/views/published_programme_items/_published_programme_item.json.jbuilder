
json.id             item.id
json.title          item.title
json.start_time     item.start_time
json.date           item.start_time.strftime('%Y-%m-%d')
json.time           item.start_time.strftime('%H:%M')
json.lock_version   item.lock_version
json.updated_at     item.updated_at
json.created_at     item.created_at

json.target_audience_id     item.target_audience_id
json.target_audience_name   item.target_audience_name
