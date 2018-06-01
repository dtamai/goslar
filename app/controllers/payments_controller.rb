# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :authenticate_customer

  def show
    payment = Customer.find(customer_id)
                      .payments.find(params[:id])

    render json: PaymentRepresenter.new(payment)
  end
end
