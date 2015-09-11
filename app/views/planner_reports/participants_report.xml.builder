xml.participants do
    @people.each do |person|
        # should be the published items
        xml.person do
            xml.name(person.getFullPublicationName)
            xml.job_title(person.job_title)
            xml.company(person.company)
            xml.photo_url(person.bio_image ? person.bio_image.bio_picture.url : '')
            xml.bio(person.bio)

            render(:partial => "participants_report_items", :locals => {:builder => xml, :assignments => person.programmeItemAssignments})
        end
    end
end