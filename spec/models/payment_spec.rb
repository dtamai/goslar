# frozen_string_literal: true

require "rails_helper"

RSpec.describe Payment do
  specify { expect(create(:payment)).to be_valid }

  describe "#payload" do
    it "casts to an object from a JSON literal" do
      payment = described_class.new(payload: '{ "key": "value" }')

      payload = payment.payload

      expect(payload.key).to eq "value"
    end

    it "casts to an object from a Hash" do
      payment = described_class.new(payload: { key: "value" })

      payload = payment.payload

      expect(payload.key).to eq "value"
    end

    it "serializes to a deserializable form" do
      payment = create :payment, payload: { key: "value" }

      payload = payment.payload

      expect(payload.key).to eq "value"
    end
  end
end
