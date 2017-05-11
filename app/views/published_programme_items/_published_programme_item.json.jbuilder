
json.id             item.id
json.title          item.title
json.start_time     item.start_time
json.date           item.start_time.strftime('%Y-%m-%d')
json.time           item.start_time.strftime('%H:%M')
json.lock_version   item.lock_version
json.updated_at     item.updated_at
json.created_at     item.created_at

json.visibility_id     item.visibility_id
json.visibility_name   item.visibility_name
