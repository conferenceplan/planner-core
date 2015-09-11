builder.bar do
    builder.details do
        builder.reference_number item.pub_reference_number
        builder.duration item.duration
        builder.format item.format.name if item.format
        builder.tracks do
            if @tagOwner
                item.owner_tag_list_on(@tagOwner, :PrimaryArea).each do |track| # TODO - check to make sure we have PrimaryArea
                    builder.track track
                end
            else
                item.tag_list_on(:PrimaryArea).each do |track| # TODO - check to make sure we have PrimaryArea
                    builder.track track
                end
            end
        end
        builder.tags do
           item.base_tags.each do |tag|
                builder.tag tag.name
           end
        end
        builder.title item.title
        builder.short_title item.short_title
        builder.description ((@short_desc && !item.short_precis.blank?) ? item.short_precis : item.precis)
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
