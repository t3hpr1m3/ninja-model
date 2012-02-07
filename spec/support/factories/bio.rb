FactoryGirl.define do
  factory :bio do
    association :user
    sequence(:name) { |n| "Name #{n}" }
    to_create { |model|
      model.write_attribute(:id, 1)
      model.stubs(:persisted?).returns(true)
      model.stubs(:new_record?).returns(false)
    }
  end
end
