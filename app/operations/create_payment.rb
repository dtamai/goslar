# frozen_string_literal: true

class CreatePayment < Operation
  def call(customer_id, params)
    return response unless validate(customer_id, params)
    process_payment(params)

    response
  end

  private

  def validate(customer_id, params)
    find_customer(customer_id)
    validate_params(params)

    ok?
  end

  def find_customer(customer_id)
    @customer = Customer.find customer_id
  end

  def validate_params(params)
    validate_buyer(params[:buyer])
    validate_payment(params[:payment])

    ok?
  end

  def process_payment(params)
    payment_params = params[:payment]
    payment = build_payment(params)
    processor = processor_for(payment_params[:type]).new(payment)
    collect! processor.call
    payment.save!
    response[:payment] = payment
  end

  def validate_buyer(buyer)
    return invalid_params! unless buyer
    return invalid_params! unless buyer.key? :cpf
    return invalid_params! unless buyer.key? :email
    return invalid_params! unless buyer.key? :name
  end

  def validate_payment(payment)
    return invalid_params! unless payment
    return invalid_params! unless payment.key? :amount
    return invalid_params! unless payment.key? :type
    return invalid_params! unless %w[boleto card].include? payment[:type]
  end

  def build_payment(params)
    @customer.payments.build payload: params
  end

  def processor_for(type)
    case type
    when "card" then CardPayment
    when "boleto" then BoletoPayment
    end
  end

  class PaymentOperation < Operation
    attr_reader :payment

    def initialize(payment)
      @payment = payment
      super()
    end

    def payment_params
      payment.payload.payment
    end

    def wait_confirmation!
      @payment.status = :waiting_payment
    end

    def reject!
      @payment.status = :rejected
    end

    def approve!
      @payment.status = :approved
    end
  end

  class CardPayment < PaymentOperation
    FAIL = /^9/

    def call
      return response unless validate_params(payment_params.card)
      process(payment_params.card)

      response
    end

    private

    def validate_params(params)
      return invalid_params! unless params
      return invalid_params! unless params[:cvv]
      return invalid_params! unless params[:expiration_date]
      return invalid_params! unless params[:holder_name]
      return invalid_params! unless params[:number]

      ok?
    end

    def process(params)
      if params[:number].match? FAIL
        reject!
        error! :payment_failed
      else
        approve!
        result!(status: "approved")
      end
    end
  end

  class BoletoPayment < PaymentOperation
    NUMBER = "1234"

    def call
      wait_confirmation!
      result!(number: NUMBER)

      response
    end
  end
end
