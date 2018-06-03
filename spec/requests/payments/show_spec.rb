# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /payments/{id}" do
  context "when id is unknown" do
    it "has status 404" do
      get_payment id: "not-a-known-id"

      expect(response.status).to eq 404
    end
  end

  context "when missing customer identification" do
    it "has status 401" do
      get_payment id: "id", customer: ""

      expect(response.status).to eq 401
    end
  end

  context "when exists a payment with given id" do
    it "has status 200" do
      payment = create :payment

      get_payment id: payment.id, customer: payment.customer_id

      expect(response.status).to eq 200
    end

    it "represents the payment" do
      payment = create :payment
      representation = represented_payment(payment)

      get_payment id: payment.id, customer: payment.customer_id

      expect(json_response[:client]).to eq representation[:client]
      expect(json_response[:status]).to eq representation[:status]
    end

    def represented_payment(payment)
      {
        client: { id: payment.customer.id },
        status: "new"
      }.as_json
    end
  end

  def get_payment(id:, customer: "customer_id")
    get "/payments/#{id}", headers: identification_for(customer)
  end

  def identification_for(customer)
    { authorization: customer }
  end
end
