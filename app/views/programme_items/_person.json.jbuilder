#
#
#
json.id person.id
json.first_name person.first_name
json.last_name person.last_name
json.suffix person.suffix
json.pseudonym person.pseudonym
json.acceptance_status_id person.acceptance_status_id
json.invitation_category_id person.invitation_category_id
json.acceptance_status_id person.acceptance_status_id
json.company person.company if person.company
json.job_title person.job_title if person.job_title
json.bio_image ((get_base_image_url + person.bio_image.bio_picture.list.url.partition(/upload/)[2]).sub! 'r_max,','') if person.bio_image
json.prog_item_count person.published_programme_items.count
json.default_email_address person.getDefaultEmail.present? ? person.getDefaultEmail.email : nil
json.default_bio_image ((get_base_image_url + DefaultBioImage.first.image.url.partition(/upload/)[2]).sub! '/upload/', '/upload/f_jpg,h_60,w_60/') if DefaultBioImage.first.image

            