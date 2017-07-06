builder.bar do
    if item.rooms[0]
        builder.room item.rooms[0].name
        builder.venue item.rooms[0].venue.name
    end
    builder.details do
        builder.reference_number item.programme_items[0].pub_reference_number
        builder.duration item.programme_items[0].duration
        builder.format item.programme_items[0].format.name if item.programme_items[0].format
        builder.tracks do
            item.programme_items[0].themes.each do |theme|
                builder.track theme.theme_name.name
            end
        end
        builder.tags do
          item.programme_items[0].taggings do |tagging|
            builder.tag tagging.tag.name
          end
        end

        builder.title item.programme_items[0].title
        builder.short_title item.programme_items[0].short_title
        builder.description do
          builder.cdata!(item.programme_items[0].precis) if item.programme_items[0].precis
        end
        builder.short_description do
          builder.cdata!(item.programme_items[0].short_precis) if item.programme_items[0].short_precis
        end

        builder.people do # we want the moderators and then participants
            item.programme_items[0].programme_item_assignments.find_all {|x| x.role == PersonItemRole['Moderator'] }.each do |p|
                builder.moderator do
                    builder.name p.person.getFullPublicationName
                    builder.job_title p.person.job_title if p.person.job_title
                    builder.company p.person.company if p.person.company
                end
            end
            item.programme_items[0].programme_item_assignments.find_all {|x| x.role == PersonItemRole['Participant'] }.each do |p|
                builder.participant do
                    builder.name p.person.getFullPublicationName
                    builder.job_title p.person.job_title if p.person.job_title
                    builder.company p.person.company if p.person.company
                end
            end
        end
    end
end
