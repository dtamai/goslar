# frozen_string_literal: true

class PaymentRepresenter < Roar::Decorator
  include Roar::JSON
  include PayloadRepresenter

  property :customer, as: :client do
    property :id
  end
  property :status
end
