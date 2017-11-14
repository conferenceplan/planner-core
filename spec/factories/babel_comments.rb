FactoryBot.define do
  factory :sociable_comment, class: 'Babel::Comment' do
    title "MyString"
    body "MyText"
    owner_id ""
    status_id ""
    parent_id ""
    published_programme_item_id ""
  end
end
