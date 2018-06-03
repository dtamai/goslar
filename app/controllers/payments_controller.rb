# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :authenticate_customer

  def show
    payment = Customer.find(customer_id)
                      .payments.find(params[:id])

    render json: PaymentRepresenter.new(payment)
  end

  def create
    result = CreatePayment.new.call(customer_id, request.request_parameters)

    if result[:error].present?
      handle_error(result)
    else
      payment = result[:payment]
      render json: result[:result], location: payment_url(payment), status: :ok
    end
  end

  private

  def handle_error(result)
    case result[:error]
    when :invalid_params
      error = OpenStruct.new(message: "Invalid or missing parameters")
      render json: ErrorRepresenter.new(error), status: :bad_request
    when :payment_failed
      error = OpenStruct.new(message: "Payment failed")
      render json: ErrorRepresenter.new(error), status: :unprocessable_entity
    else
      head :unpocessable_entity
    end
  end
end
