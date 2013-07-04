FactoryGirl.define do
  factory :bio do
    association :user
    sequence(:name) { |n| "Name #{n}" }
    to_create { |model|
      model.write_attribute(:id, 1)
      model.stubs(persisted?: true, new_record?: false)
    }
  end
end
