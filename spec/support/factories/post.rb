FactoryGirl.define do
  factory :post do
    association :user
    sequence(:title) { |n| "Title #{n}" }
    published false
    to_create { |model|
      model.write_attribute(:id, 1)
      model.stubs(:persisted?).returns(true)
      model.stubs(:new_record?).returns(false)
    }
  end
end
