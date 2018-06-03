# frozen_string_literal: true

module PayloadRepresenter
  include Roar::JSON

  property :buyer do
    property :cpf
    property :email
    property :name
  end

  property :payment do
    property :amount
    property :type

    property :card do
      property :cvv
      property :expiration_date
      property :holder_name
      property :number
    end

    property :boleto do
      property :number
    end
  end
end
