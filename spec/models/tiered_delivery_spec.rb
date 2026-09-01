require 'rails_helper'

RSpec.describe TieredDelivery do
  subject(:delivery) do
    described_class.new([[0...50, "4.95"], [50...90, "2.95"], [90.., 0]])
  end

  describe "#charge_for" do
    context "with a subtotal under $50" do
      it "charges $4.95 for an empty basket" do
        expect(delivery.charge_for(BigDecimal("0"))).to eq(BigDecimal("4.95"))
      end

      it "charges $4.95 just below the boundary" do
        expect(delivery.charge_for(BigDecimal("49.99"))).to eq(BigDecimal("4.95"))
      end
    end

    context "with a subtotal from $50 up to $90" do
      it "charges $2.95 at exactly $50" do
        expect(delivery.charge_for(BigDecimal("50"))).to eq(BigDecimal("2.95"))
      end

      it "charges $2.95 just below $90" do
        expect(delivery.charge_for(BigDecimal("89.99"))).to eq(BigDecimal("2.95"))
      end
    end

    context "with a subtotal of $90 or more" do
      it "is free at exactly $90" do
        expect(delivery.charge_for(BigDecimal("90"))).to eq(BigDecimal("0"))
      end

      it "is free above $90" do
        expect(delivery.charge_for(BigDecimal("150"))).to eq(BigDecimal("0"))
      end
    end
  end
end
