class TieredDelivery
  def initialize(tiers)
    @tiers = tiers.map { |range, cost| [ range, BigDecimal(cost.to_s) ] }
  end

  def charge_for(subtotal)
    _, cost = @tiers.find { |range, _| range.cover?(subtotal) }
    cost || BigDecimal("0")
  end
end
