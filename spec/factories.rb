FactoryGirl.define do
  factory :user do
    name  "John Botica"
    email "john@digital-telepathy.com"
    password "foobar"
    password_confirmation "foobar"
  end
end