require 'active_record'
require 'pg'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: ENV['DB_NAME'],
  host: 'localhost'
)

# Silence logger for cleaner output, but you can enable it for debugging
# ActiveRecord::Base.logger = Logger.new(STDOUT)

class Category < ActiveRecord::Base
  has_many :products
  scope :active, -> { where(active: true) }
end

class Product < ActiveRecord::Base
  belongs_to :category
  scope :affordable, -> { where("price < 100") }
  scope :available, -> { where(discontinued: false) }
end

# --- YOUR TASK ---
# 1. Implement a method to find products that are EITHER 'affordable' OR 'available'.
# 2. Implement a method to find products belonging to an 'active' category using .merge.

class ProductSearch
  def self.affordable_or_available
    Product.affordable.or(Product.available)
  end

  def self.in_active_categories
    Product.joins(:category).merge(Category.active)
  end
end

# --- TEST SUITE ---
# 1. OR Test
res1 = ProductSearch.affordable_or_available
raise "OR failed: Should include Laptop (available) and Phone (available)" unless res1.map(&:name).include?("Laptop")
raise "OR failed: Should include Old Book (affordable)" unless res1.map(&:name).include?("Old Book")
puts "✅ .or combined successfully"

# 2. Merge Test
res2 = ProductSearch.in_active_categories
raise "Merge failed: Should only include products from Electronics" if res2.map(&:name).include?("Old Book")
raise "Merge failed: Missing Electronics products" unless res2.map(&:name).include?("Laptop")
puts "✅ .merge applied successfully"

puts "✨ KATA COMPLETE!"
