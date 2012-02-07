FactoryGirl.define do
  factory :email_address do
    sequence(:email) { |n| "user#{n}@example.com" }
  end
end
