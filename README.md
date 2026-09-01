# Acme Widget Co - Basket

Proof of concept for Acme Widget Co's new sales system: a shopping basket that
prices orders from a product catalogue, applies special offers, and adds a
delivery charge based on how much the customer spends.

## Requirements

* Ruby 3.3.8 (see `.ruby-version`)
* Bundler

## Setup

```sh
bundle install
bin/rails db:prepare
bin/rails db:seed
```

The seeds load the three widgets from the brief: Red (R01, $32.95),
Green (G01, $24.95) and Blue (B01, $7.95).

## Running the tests

```sh
bundle exec rspec
```

## Usage

The basket is a plain Ruby object. From `bin/rails console`:

```ruby
basket = Basket.new(
  catalogue: Product.all,
  delivery_rules: TieredDelivery.new([[0...50, "4.95"], [50...90, "2.95"], [90.., 0]]),
  offers: [Offers::BuyOneGetSecondHalfPrice.new("R01")]
)

basket.add("R01")
basket.add("R01")
basket.total # => 54.37 (BigDecimal)
```

## How it works

`Basket` is a small orchestrator. It knows nothing about concrete prices,
discounts or shipping tiers. All three are injected when the basket is built:

* The catalogue is anything that responds to `code` and `price` per item.
  Here it is the `Product` ActiveRecord model, which owns the validations
  and the seed data, but the basket does not depend on the database.
* `TieredDelivery` receives the tiers as ranges paired with costs, so the
  boundaries live in data instead of code. The charge is picked from the
  subtotal after discounts.
* Offers are a list of objects that respond to `discount(items)`. The launch
  offer, `Offers::BuyOneGetSecondHalfPrice`, counts pairs of the given
  product and returns the money to subtract. New offers mean new classes,
  not changes to the basket.

`total` computes the item subtotal, subtracts every offer's discount, and
adds the delivery charge for the discounted amount.

All money math uses `BigDecimal` from end to end. Floats are never used for
prices because most decimal amounts are not exactly representable in binary
floating point, and the errors show up as off-by-a-cent totals.

## Assumptions

* Half price of $32.95 is $16.475, which is not a chargeable amount. The
  discounted widget sells for the half price floored to whole cents ($16.47),
  so the discount per pair is $16.48. The expected totals from the brief
  ($54.37 and $98.27) only work out in this direction.
* Delivery is charged on the subtotal after discounts, which is what the
  brief's examples imply.
* Adding an unknown product code raises `ArgumentError` rather than failing
  silently.
* An empty basket totals $4.95, the base delivery charge, since the rules
  put no lower bound on it. Easy to change if the business decides otherwise.
* `total` returns a `BigDecimal`; formatting it as `"$54.37"` is left to the
  caller.

## TODO

Things a real version should pick up later:

* Removing items from the basket, and quantities instead of repeated `add` calls
* Formatted money output, since `total` returns a raw `BigDecimal`
* More offer types beyond the launch one
* Persisting baskets instead of holding them in memory
* Deciding whether an empty basket should really charge the base delivery
* Admin screens or CRUD for products, offers, and delivery rules
