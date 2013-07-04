FactoryGirl.define do
  factory :body do
    association :post
    sequence(:text) { |n| "Body #{n}" }
    to_create { |model|
      model.write_attribute(:id, 1)
      model.stubs(persisted?: true, new_record?: false)
    }
  end
end

