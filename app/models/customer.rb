# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :payments, dependent: :restrict_with_exception
end
