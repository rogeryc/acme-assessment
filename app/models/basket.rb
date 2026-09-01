class Basket
  def initialize(catalogue:, delivery_rules:, offers:)
    @catalogue = catalogue
    @delivery_rules = delivery_rules
    @offers = offers
    @items = []
  end

  def add(code)
    product = @catalogue.find { |p| p.code == code }
    raise ArgumentError, "unknown product code: #{code}" unless product

    @items << product
  end

  def total
    discounted = subtotal - discounts
    discounted + @delivery_rules.charge_for(discounted)
  end

  private

  def subtotal
    @items.sum(BigDecimal("0"), &:price)
  end

  def discounts
    @offers.sum(BigDecimal("0")) { |offer| offer.discount(@items) }
  end
end
