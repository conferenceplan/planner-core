FactoryGirl.define do
  factory :default_site_config, class: SiteConfig do
    name 'MyConvention'
    start_date '01/02/2016'
  end
end
