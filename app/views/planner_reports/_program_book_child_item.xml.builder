builder.bar do
    builder.details do
        builder.reference_number item.pub_reference_number
        builder.duration item.duration
        builder.format item.format.name if item.format
        builder.tracks do
            item.themes.each do |theme|
                builder.track theme.theme_name.name
            end
        end
        builder.tags do
          item.taggings do |tagging|
            builder.tag tagging.tag.name
          end
        end
        # builder.tags do
        #    item.base_tags.each do |tag|
        #         builder.tag tag.name
        #    end
        # end
        builder.title item.title
        builder.short_title item.short_title
        builder.description do
          builder.cdata!(item.precis) if item.precis
        end
        builder.short_description do
          builder.cdata!(item.short_description) if item.short_description
        end
        builder.people do # we want the moderators and then participants
            item.programme_item_assignments.find_all {|x| x.role == PersonItemRole['Moderator'] }.each do |p|
                builder.moderator do
                    builder.name p.person.getFullPublicationName
                    builder.job_title p.person.job_title if p.person.job_title
                    builder.company p.person.company if p.person.company
                end
            end
            item.programme_item_assignments.find_all {|x| x.role == PersonItemRole['Participant'] }.each do |p|
                builder.participant do
                    builder.name p.person.getFullPublicationName
                    builder.job_title p.person.job_title if p.person.job_title
                    builder.company p.person.company if p.person.company
                end
            end
        end
    end
end
