# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /payments" do
  let(:valid_params) do
    {
      buyer: { name: "", email: "", cpf: "" },
      payment: { amount: "", type: "boleto" }
    }
  end

  let(:invalid_params) do
    {
      not_buyer: { name: "", email: "", cpf: "" },
      not_payment: { amount: "", type: "boleto" }
    }
  end

  let(:valid_headers) { { authorization: create(:customer).id } }
  let(:invalid_headers) { { authorization: "" } }

  context "when there is an invalid parameter" do
    it "has status 400" do
      post_payment params: invalid_params

      expect(response.status).to eq 400
    end
  end

  context "when missing customer identification" do
    it "has status 401" do
      post_payment headers: invalid_headers

      expect(response.status).to eq 401
    end
  end

  context "when both params and authentication are valid" do
    it "has status 201" do
      post_payment params: valid_params, headers: valid_headers

      expect(response.status).to eq 200
    end
  end

  def post_payment(params: valid_params, headers: valid_headers)
    post "/payments", params: params, headers: headers
  end
end
