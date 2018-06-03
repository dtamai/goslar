# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :customer

  attribute :payload, Payload.new

  delegate :buyer, :payment, :card, to: :payload
end
