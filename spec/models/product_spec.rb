require 'rails_helper'

RSpec.describe Product, type: :model do
  context "with all attributes" do
    it "is valid" do
      expect(build(:product)).to be_valid
    end
  end

  context "with name" do
    it "requires presence" do
      product = build(:product, name: nil)
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include("can't be blank")
    end
  end

  context "with code" do
    it "requires presence" do
      product = build(:product, code: nil)
      expect(product).not_to be_valid
      expect(product.errors[:code]).to include("can't be blank")
    end

    it "requires uniqueness" do
      create(:product, code: "R01")
      product = build(:product, code: "R01")
      expect(product).not_to be_valid
      expect(product.errors[:code]).to include("has already been taken")
    end
  end

  context "with price" do
    it "requires presence" do
      product = build(:product, price: nil)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("can't be blank")
    end

    it "rejects a negative value" do
      product = build(:product, price: "-0.01")
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("must be greater than or equal to 0")
    end

    it "allows zero" do
      expect(build(:product, price: 0)).to be_valid
    end

    it "is returned as a BigDecimal" do
      product = create(:product, price: "32.95")
      expect(product.reload.price).to be_a(BigDecimal)
      expect(product.price).to eq(BigDecimal("32.95"))
    end
  end
end
