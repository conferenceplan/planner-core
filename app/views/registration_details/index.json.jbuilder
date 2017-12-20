
if @registrationDetail
    json.id @registrationDetail.id
    json.lock_version @registrationDetail.lock_version
    json.person_id @registrationDetail.person_id
    json.registration_number @registrationDetail.registration_number
    json.registration_type @registrationDetail.registration_type 
    json.registered @registrationDetail.registered
    json.can_share @registrationDetail.can_share
    json.lock_version @registrationDetail.lock_version
end
