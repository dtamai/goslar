# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    customer
    payload({})
  end
end
