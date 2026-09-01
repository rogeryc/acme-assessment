require 'rails_helper'

RSpec.describe Offers::BuyOneGetSecondHalfPrice do
  subject(:offer) { described_class.new("R01") }

  let(:red) { build(:product, code: "R01", price: "32.95") }
  let(:green) { build(:product, code: "G01", name: "Green Widget", price: "24.95") }

  describe "#discount" do
    context "without a pair" do
      it "gives no discount for an empty basket" do
        expect(offer.discount([])).to eq(BigDecimal("0"))
      end

      it "gives no discount for a single red widget" do
        expect(offer.discount([ red ])).to eq(BigDecimal("0"))
      end

      it "ignores other products" do
        expect(offer.discount([ green, green ])).to eq(BigDecimal("0"))
      end
    end

    context "with a pair" do
      it "gives a discount for the second product" do
        expect(offer.discount([ red, red ])).to eq(BigDecimal("16.48"))
      end

      it "keeps the discount in whole cents when the half price falls on a half cent" do
        cheap = build(:product, code: "R01", price: "0.05")
        expect(offer.discount([ cheap, cheap ])).to eq(BigDecimal("0.03"))
      end
    end
  end
end
