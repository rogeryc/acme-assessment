[
  { name: "Red Widget", code: "R01", price: "32.95" },
  { name: "Green Widget", code: "G01", price: "24.95" },
  { name: "Blue Widget", code: "B01", price: "7.95" }
].each do |attrs|
  Product.find_or_create_by!(code: attrs[:code]) do |product|
    product.name = attrs[:name]
    product.price = attrs[:price]
  end
end
