require 'rails_helper'

RSpec.describe Basket do
  subject(:basket) do
    described_class.new(
      catalogue: [
        build(:product, name: "Red Widget", code: "R01", price: "32.95"),
        build(:product, name: "Green Widget", code: "G01", price: "24.95"),
        build(:product, name: "Blue Widget", code: "B01", price: "7.95")
      ],
      delivery_rules: TieredDelivery.new([ [ 0...50, "4.95" ], [ 50...90, "2.95" ], [ 90.., 0 ] ]),
      offers: [ Offers::BuyOneGetSecondHalfPrice.new("R01") ]
    )
  end

  def add_all(*codes)
    codes.each { |code| basket.add(code) }
  end

  describe "#add" do
    it "raises for an unknown product code" do
      expect { basket.add("X99") }.to raise_error(ArgumentError, /X99/)
    end
  end

  describe "#total" do
    context "with the example baskets from the brief" do
      it "totals $37.85 for B01, G01 with small order delivery" do
        add_all("B01", "G01")
        # 7.95 + 24.95 = 32.90 goods + 4.95 (delivery <50)
        expect(basket.total).to eq(BigDecimal("37.85"))
      end

      it "totals $54.37 for R01, R01 applying the half price offer" do
        add_all("R01", "R01")
        # 32.95 + 16.47 (floored half of 32.95) = 49.42 goods + 4.95 (delivery <50)
        expect(basket.total).to eq(BigDecimal("54.37"))
      end

      it "totals $60.85 for R01, G01 with no offer and mid tier delivery" do
        add_all("R01", "G01")
        # 32.95 + 24.95 = 57.90 goods (single red, no offer) + 2.95 (delivery between 50-90)
        expect(basket.total).to eq(BigDecimal("60.85"))
      end

      it "totals $98.27 for B01, B01, R01, R01, R01 with the offer and free delivery" do
        add_all("B01", "B01", "R01", "R01", "R01")
        # 7.95 + 7.95 + 32.95 + 32.95 + 32.95 - 16.48 (one red pair) = 98.27 goods + 0 (delivery >90)
        expect(basket.total).to eq(BigDecimal("98.27"))
      end
    end

    context "with an empty basket" do
      it "charges only the base delivery" do
        expect(basket.total).to eq(BigDecimal("4.95"))
      end
    end
  end
end
