type = type || nil
default_img = default_img || nil
#
#
#
json.id person.id
json.real_name person.full_name
json.full_publication_name person.full_publication_name
json.first_name person.first_name
json.last_name person.last_name
json.suffix person.suffix
json.pseudonym person.pseudonym
if person.person_con_state
  json.acceptance_status_id person.person_con_state.acceptance_status_id
  json.invitestatus_id person.person_con_state.invitestatus_id
  json.invitation_category_id person.person_con_state.invitation_category_id
else
  json.acceptance_status_id nil
  json.invitestatus_id nil
  json.invitation_category_id nil
end
json.company person.company if person.company
json.job_title person.job_title if person.job_title
json.bio_image person_img_url(person, default_img: default_img)
json.prog_item_count person.published_programme_items.count
json.default_email_address person.getDefaultEmail.present? ? person.getDefaultEmail.email : nil
json.assignment_type type
