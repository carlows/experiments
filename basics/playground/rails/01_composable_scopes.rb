require 'active_record'
require 'pg'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: ENV['DB_NAME'],
  host: 'localhost'
)

class Category < ActiveRecord::Base
  has_many :products
  scope :active, -> { where(active: true) }
  scope :with_name, ->(name) { where(name: name) }
end

class Product < ActiveRecord::Base
  belongs_to :category
  has_many :tags
  
  scope :affordable, -> { where("price < 100") }
  scope :available, -> { where(discontinued: false) }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { where("created_at > ?", 1.day.ago) }
end

class Tag < ActiveRecord::Base; belongs_to :product; end

# --- YOUR MISSION ---
# Implement these 10 advanced query patterns using pure ActiveRecord.

class ProductSearch
  # 1. Basic Union: Affordable OR Available
  def self.affordable_or_available
    Product.affordable.or(Product.available)
  end

  # 2. Scope Merging: Products in 'active' categories
  def self.in_active_categories
    Product.joins(:category).merge(Category.active)
  end

  # 3. Negative Merging: Products NOT in active categories
  # Hint: You can use .where.not(...) with a subquery or a manual join
  def self.in_inactive_categories
    Product.joins(:category).where(category: { active: false })
  end

  # 4. The Unscope: Find all products, ignoring any 'available' scope applied previously
  def self.all_even_discontinued(relation)
    relation.unscope(where: [:discontinued])
  end

  # 5. The Rewhere: Change a price filter from < 100 to < 50
  def self.tighter_budget(relation)
    # Feedback: rewhere can't be used with string queries
    # Although its good to know, so perhaps keep it but also
    # provide a good example
    relation.unscope(:where).where('price < 50')
  end

  # 6. Dynamic Join Scoping: Products with a specific tag name
  def self.with_tag(tag_name)
    Product.joins(:tags).where(tags: { name: tag_name })
  end

  # 7. Multi-merge: Featured products in Active categories
  def self.featured_and_active
    # Feedback: not clear why using multi-merge here
    Product.featured.joins(:category).merge(Category.active)
  end

  # 8. The None: Return an empty relation that doesn't hit the DB
  def self.abort_search
    Product.none
  end

  # 9. Anonymous Extensions: Add a 'total_price' method to the returned relation
  def self.with_stats
    Product.all.extending do
      def total_price
        sum(:price)
      end
    end
  end

  # 10. Re-ordering: Ignore existing orders and sort by price ASC
  def self.cheapest_first(relation)
    relation.reorder(price: :asc)
  end
end

# --- TEST SUITE ---
puts "Starting 10-Stage Verification..."

# 1. OR
res = ProductSearch.affordable_or_available
raise "Ex 1 Failed: Expected affordable OR available" unless res&.count >= 3
puts "✅ Ex 1 Passed"

# 2. Merge
res = ProductSearch.in_active_categories
raise "Ex 2 Failed: Should only be in active categories" if res&.any? { |p| !p.category.active }
puts "✅ Ex 2 Passed"

# 3. Inactive Merge
res = ProductSearch.in_inactive_categories
raise "Ex 3 Failed" if res&.any? { |p| p.category.active }
puts "✅ Ex 3 Passed"

# 4. Unscope
rel = Product.available
res = ProductSearch.all_even_discontinued(rel)
raise "Ex 4 Failed" unless res&.count > rel.count
puts "✅ Ex 4 Passed"

# 5. Rewhere
rel = Product.where("price < 100")
res = ProductSearch.tighter_budget(rel)
puts "res: #{res.to_sql}"
raise "Ex 5 Failed" if res&.to_sql&.include?("100")
puts "✅ Ex 5 Passed"

# 6. Tag Join
Tag.create!(name: "tech", product: Product.first)
res = ProductSearch.with_tag("tech")
raise "Ex 6 Failed" unless res&.first == Product.first
puts "✅ Ex 6 Passed"

# 7. Multi-merge
res = ProductSearch.featured_and_active
raise "Ex 7 Failed" unless res&.count == 1
puts "✅ Ex 7 Passed"

# 8. None
res = ProductSearch.abort_search
raise "Ex 8 Failed" unless res.is_a?(ActiveRecord::Relation) && res.empty?
puts "✅ Ex 8 Passed"

# 9. Extending
res = ProductSearch.with_stats
raise "Ex 9 Failed" unless res.respond_to?(:total_price)
puts "✅ Ex 9 Passed"

# 10. Reorder
rel = Product.order(name: :desc)
res = ProductSearch.cheapest_first(rel)
raise "Ex 10 Failed" if res.to_sql.downcase.include?("order by \"products\".\"name\" desc")
puts "✅ Ex 10 Passed"

puts "🏆 ALL STAGES COMPLETE!"
