# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreatePayment do
  subject(:operation) { described_class.new }

  let(:valid_params) do
    {
      buyer: {
        cpf: "12345678900",
        email: "alice@example.com",
        name: "Alice"
      },
      payment: {
        amount: "1.0",
        type: "card",
        card: {
          cvv: "123",
          expiration_date: "09/19",
          holder_name: "ALICE",
          number: "1234 5678 9012 3456"
        }
      }
    }
  end
  let(:customer_id) { create(:customer).id }

  shared_examples_for "validating parameters" do
    it "fails with parameter error" do
      response = operation.call customer_id, params

      expect(response[:error]).to eq :invalid_params
    end
  end

  context "when customer_id is missing" do
    let(:customer_id) { "" }

    it "raises not found exception" do
      expect { operation.call customer_id, valid_params }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when buyer is invalid" do
    it_behaves_like "validating parameters" do
      let(:params) do
        valid_params.tap { |vp| vp.delete :buyer }
      end
    end

    [:cpf, :email, :name].each do |attribute_name|
      context "when #{attribute_name} is missing" do
        let(:params) do
          valid_params.tap { |vp| vp[:buyer].delete attribute_name }
        end

        it_behaves_like "validating parameters"
      end
    end
  end

  context "when payment is invalid" do
    it_behaves_like "validating parameters" do
      let(:params) do
        valid_params.tap { |vp| vp.delete :payment }
      end
    end

    [:amount, :type].each do |attribute_name|
      context "when #{attribute_name} is missing" do
        let(:params) do
          valid_params.tap { |vp| vp[:payment].delete attribute_name }
        end

        it_behaves_like "validating parameters"
      end
    end

    context "when payment type is invalid" do
      let(:params) do
        valid_params[:payment][:type] = :bad_type
        valid_params
      end

      it_behaves_like "validating parameters"
    end
  end

  context "when parameters are valid" do
    it "succeeds without error" do
      response = operation.call customer_id, valid_params

      expect(response[:error]).to be_nil
    end
  end

  context "when type is boleto" do
    let(:params) do
      valid_params[:payment][:type] = "boleto"
      valid_params[:payment].delete :card
      valid_params
    end

    it "returns its number" do
      response = operation.call customer_id, params

      expect(response[:result]).to eq(number: CreatePayment::BoletoPayment::NUMBER)
    end
  end

  context "when type is card" do
    let(:params) { valid_params }

    [:cvv, :expiration_date, :holder_name, :number].each do |attribute_name|
      context "when #{attribute_name} is missing" do
        let(:params) do
          valid_params.tap { |vp| vp[:payment][:card].delete attribute_name }
        end

        it_behaves_like "validating parameters"
      end
    end

    context "when number begins with 9 (stubbed failure)" do
      let(:params) do
        number = valid_params.dig(:payment, :card, :number).sub(/\d/, "9")
        valid_params[:payment][:card][:number] = number
        valid_params
      end

      it "errors with failed payment" do
        response = operation.call customer_id, params

        expect(response[:error]).to eq :payment_failed
      end
    end

    context "when number does not begin with 9 (stubbed success)" do
      it "succeeds" do
        response = operation.call customer_id, valid_params

        expect(response[:result][:status]).to eq "approved"
      end
    end
  end
end
