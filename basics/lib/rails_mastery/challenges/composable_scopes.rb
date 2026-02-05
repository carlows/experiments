require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class ComposableScopes < RailsChallenge
      def initialize
        super('The Composable Scope (ActiveRecord Mastery)', '01_composable_scopes.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :categories, force: true do |t|
            t.string :name
            t.boolean :active, default: true
          end

          create_table :products, force: true do |t|
            t.string :name
            t.integer :price
            t.integer :category_id
            t.boolean :discontinued, default: false
          end
        end
      end

      def seed_data
        electronics = Category.create!(name: 'Electronics', active: true)
        books = Category.create!(name: 'Books', active: false)

        Product.create!(name: 'Laptop', price: 1000, category: electronics)
        Product.create!(name: 'Phone', price: 500, category: electronics)
        Product.create!(name: 'Old Book', price: 10, category: books)
        Product.create!(name: 'New Book', price: 20, category: books, discontinued: true)
      end

      def write_kata_file
        content = <<~RUBY
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
              # TODO: Use .or to combine two scopes
            end

            def self.in_active_categories
              # TODO: Use .joins and .merge to apply Category.active scope to Product query
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
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. The `.or` Operator
          ActiveRecord's `.or` allows you to perform SQL UNION-like operations without writing raw strings.#{' '}
          *Expert Tip:* To use `.or`, both relations must have the same structural properties (e.g., same joins, same where clauses except for the OR part).

          ### 2. The `.merge` Powerhouse
          *Effective Rails Practice:* Instead of duplicating logic (`Product.joins(:category).where(categories: { active: true })`), you should reuse the existing scope from the associated model.#{' '}
          `Product.joins(:category).merge(Category.active)` is cleaner, more maintainable, and encapsulates the logic of what an "active" category is within the `Category` model itself.

          ### 3. Cross-Model Scoping
          `.merge` is essential when building complex search filters where you want to apply filters from multiple tables while keeping your models decoupled.
        TEXT
      end
    end
  end
end

# Define models temporarily for seeding (will be redefined in the kata file)
class Category < ActiveRecord::Base; has_many :products; end

class Product < ActiveRecord::Base; belongs_to :category; end
