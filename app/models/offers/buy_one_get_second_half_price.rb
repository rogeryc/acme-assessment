module Offers
  class BuyOneGetSecondHalfPrice
    def initialize(code)
      @code = code
    end

    def discount(items)
      matching = items.select { |item| item.code == @code }
      pairs = matching.size / 2
      return BigDecimal("0") if pairs.zero?

      pairs * (matching.first.price / 2)
    end
  end
end
