json.array!(@programme_item_assignments) do |programme_item_assignment|
    json.partial! 'assignment', assignment: programme_item_assignment
end
