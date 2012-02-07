FactoryGirl.define do
  factory :body do
    association :post
    sequence(:text) { |n| "Body #{n}" }
    to_create { |model|
      model.write_attribute(:id, 1)
      model.stubs(:persisted?).returns(true)
      model.stubs(:new_record?).returns(false)
    }
  end
end

