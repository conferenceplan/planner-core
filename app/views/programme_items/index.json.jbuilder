
json.array!(@assignments) do |assignment|
    if assignment.programmeItem

        json.partial! 'base_item', item: assignment.programmeItem, role: assignment.role.name

    end
end
