class Product < ApplicationRecord
  validates :name, :code, :price, presence: true
  validates :code, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
