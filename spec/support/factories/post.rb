FactoryGirl.define do
  factory :post do
    association :user
    sequence(:title) { |n| "Title #{n}" }
    published false
    to_create { |model|
      model.write_attribute(:id, 1)
      model.stubs(persisted?: true, new_record?: false)
    }
  end
end
