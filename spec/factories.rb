FactoryGirl.define do
  sequence(:name) {|n| "User #{n}"}
  factory :user do
    name
  end
end
