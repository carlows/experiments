require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class ComposableScopes < RailsChallenge
      def initialize
        super('The Composable Scope (10-Stage Mastery)', '01_composable_scopes.rb')
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
            t.boolean :featured, default: false
            t.datetime :created_at
          end

          create_table :tags, force: true do |t|
            t.string :name
            t.integer :product_id
          end
        end
      end

      def seed_data
        electronics = Category.create!(name: 'Electronics', active: true)
        books = Category.create!(name: 'Books', active: false)

        Product.create!(name: 'Laptop', price: 1000, category: electronics, featured: true, created_at: 2.days.ago)
        Product.create!(name: 'Phone', price: 500, category: electronics, created_at: 1.hour.ago)
        Product.create!(name: 'Old Book', price: 10, category: books, created_at: 1.year.ago)
        Product.create!(name: 'New Book', price: 20, category: books, discontinued: true, created_at: 5.minutes.ago)
      end

      def write_kata_file
        content = <<~RUBY
          class Category < ActiveRecord::Base
            has_many :products
            scope :active, -> { where(active: true) }
            scope :with_name, ->(name) { where(name: name) }
          end

          class Product < ActiveRecord::Base
            belongs_to :category
            has_many :tags
          #{'  '}
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
            end

            # 2. Scope Merging: Products in 'active' categories
            def self.in_active_categories
            end

            # 3. Negative Merging: Products NOT in active categories
            # Hint: You can use .where.not(...) with a subquery or a manual join
            def self.in_inactive_categories
            end

            # 4. The Unscope: Find all products, ignoring any 'available' scope applied previously
            def self.all_even_discontinued(relation)
            end

            # 5. The Rewhere: Change a price filter from < 100 to < 50
            def self.tighter_budget(relation)
            end

            # 6. Dynamic Join Scoping: Products with a specific tag name
            def self.with_tag(tag_name)
            end

            # 7. Multi-merge: Featured products in Active categories
            def self.featured_and_active
            end

            # 8. The None: Return an empty relation that doesn't hit the DB
            def self.abort_search
            end

            # 9. Anonymous Extensions: Add a 'total_price' method to the returned relation
            def self.with_stats
            end

            # 10. Re-ordering: Ignore existing orders and sort by price ASC
            def self.cheapest_first(relation)
            end
          end

          # --- TEST SUITE (DO NOT MODIFY) ---
          @stages_passed = 0
          def verify_stage(name)
            yield
            puts "✅ \#{name} Passed"
            @stages_passed += 1
          rescue => e
            puts "❌ \#{name} Failed: \#{e.message}"
          end

          puts "Starting 10-Stage Verification..."

          # 1. OR
          verify_stage("Stage 1 (OR Union)") do
            res = ProductSearch.affordable_or_available
            raise "Expected Relation" unless res.is_a?(ActiveRecord::Relation)
            raise "Missing available products" unless res.map(&:name).include?("Laptop")
            raise "Missing affordable products" unless res.map(&:name).include?("Old Book")
          end

          # 2. Merge
          verify_stage("Stage 2 (Scope Merge)") do
            res = ProductSearch.in_active_categories
            raise "Inactive categories included" if res.any? { |p| !p.category.active }
            raise "Electronics missing" unless res.map(&:name).include?("Laptop")
          end

          # 3. Inactive
          verify_stage("Stage 3 (Negative Merge)") do
            res = ProductSearch.in_inactive_categories
            raise "Active categories included" if res.any? { |p| p.category.active }
            raise "Books missing" unless res.map(&:name).include?("Old Book")
          end

          # 4. Unscope
          verify_stage("Stage 4 (Unscope)") do
            rel = Product.available
            res = ProductSearch.all_even_discontinued(rel)
            raise "Still scoped to available" unless res.count > rel.count
          end

          # 5. Rewhere
          verify_stage("Stage 5 (Rewhere)") do
            rel = Product.where("price < 100")
            res = ProductSearch.tighter_budget(rel)
            raise "Filter not tightened" if res.to_sql.include?("100")
          end

          # 6. Tag Join
          verify_stage("Stage 6 (Join Scoping)") do
            Tag.create!(name: "tech", product: Product.first)
            res = ProductSearch.with_tag("tech")
            raise "Tag search failed" unless res.first == Product.first
          end

          # 7. Multi-merge
          verify_stage("Stage 7 (Multi-merge)") do
            res = ProductSearch.featured_and_active
            raise "Multi-merge mismatch" unless res.count == 1
          end

          # 8. None
          verify_stage("Stage 8 (Abort Search)") do
            res = ProductSearch.abort_search
            raise "Not a NullRelation" unless res.is_a?(ActiveRecord::Relation) && res.empty?
          end

          # 9. Extending
          verify_stage("Stage 9 (Relation Extensions)") do
            res = ProductSearch.with_stats
            raise "Extension missing" unless res.respond_to?(:total_price)
          end

          # 10. Reorder
          verify_stage("Stage 10 (Reorder)") do
            rel = Product.order(name: :desc)
            res = ProductSearch.cheapest_first(rel)
            raise "Not reordered" if res.to_sql.downcase.include?("name desc")
          end

          if @stages_passed == 10
            puts "\n🏆 ALL STAGES COMPLETE! You are a Scope Master."
          else
            puts "\n❌ You passed \#{@stages_passed}/10 stages. Keep going!"
            exit 1
          end
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `.merge` and `.or`
          `.merge` is the most important tool for keeping models decoupled. It allows you to reuse logic from associated models. `.or` provides a clean way to handle unions without falling back to raw SQL strings.

          ### 2. `unscope`, `rewhere`, and `reorder`
          These are "Query Mutation" tools. They allow a method to receive an existing relation and "fix" or "override" parts of it. This is crucial for building flexible search objects.

          ### 3. `.extending`
          This allows you to add specific methods to a particular *instance* of a relation. It's often used for pagination (like `Kaminari`) or custom reporting methods that only make sense in the context of a filtered list.

          ### 4. `.none`
          This returns an `NullRelation`. It's a "Safe" way to abort a query chain. It looks and acts like a normal relation but guarantees no SQL will ever be sent to the database.
        TEXT
      end
    end
  end
end

class Category < ActiveRecord::Base; has_many :products; end

class Product < ActiveRecord::Base
  belongs_to :category
  has_many :tags
end

class Tag < ActiveRecord::Base; belongs_to :product; end
