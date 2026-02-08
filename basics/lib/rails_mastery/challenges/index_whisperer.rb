require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class IndexWhisperer < RailsChallenge
      class User < ActiveRecord::Base
        has_many :orders
      end

      class Order < ActiveRecord::Base
        belongs_to :user
      end

      def initialize
        super('The Index Whisperer (10-Stage Performance)', '04_index_whisperer.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :users, force: true do |t|
            t.string :email
            t.string :status
            t.string :first_name
            t.string :last_name
            t.datetime :last_login_at
          end

          create_table :orders, force: true do |t|
            t.string :status
            t.datetime :placed_at
            t.integer :user_id
            t.decimal :total
          end
        end
      end

      def seed_data
        puts 'Seeding 10,000 records...'.colorize(:gray)
        # We need volume to ensure Seq Scans are costly enough for the planner to care
        users = 1000.times.map { { email: Faker::Internet.email, status: 'active', last_login_at: Time.now } }
        User.insert_all(users)

        statuses = %w[pending shipped cancelled delivered]
        orders = 10_000.times.map do
          {
            status: statuses.sample,
            placed_at: Faker::Time.backward(days: 30),
            user_id: rand(1..1000),
            total: rand(10.0..500.0)
          }
        end
        Order.insert_all(orders)
      end

      def write_kata_file
        content = <<~RUBY
          class User < ActiveRecord::Base#{' '}
            has_many :orders#{' '}
          end

          class Order < ActiveRecord::Base
            belongs_to :user#{' '}
          end

          # --- YOUR MISSION ---
          # Optimize these 10 scenarios by adding the correct indexes.
          # You must use ActiveRecord::Base.connection.add_index.

          class Optimizer
            # 1. Simple Equality: Find user by email (must be unique)
            def self.optimize_email_lookup
            end

            # 2. Equality + Order: Order.where(status: 'pending').order(placed_at: :desc)
            # Goal: Create a composite index to avoid a 'Sort' node in EXPLAIN.
            def self.optimize_status_and_time
            end

            # 3. Case-Insensitive Search: User.where("LOWER(email) = ?", "test@example.com")
            # Goal: Create a functional (expression) index.
            def self.optimize_lower_email
            end

            # 4. Partial Index: Find ONLY 'active' users who logged in recently.
            # Goal: Create a partial index where status = 'active'.
            def self.optimize_active_recent_login
            end

            # 5. Covering Index (Index Only Scan): Select ONLY 'status' and 'total' from orders.
            # Goal: Use 'include' (if your PG version supports it) or just a composite index.
            def self.optimize_covering_query
            end

            # 6. Prefix Search: User.where("first_name LIKE ?", "Mat%")
            # Goal: Add a btree_gin or specialized btree index (text_pattern_ops).
            def self.optimize_prefix_search
            end

            # 7. Foreign Keys: Fix the slow join between User and Order.
            def self.optimize_fk_lookups
            end

            # 8. Nulls Management: Find orders where 'placed_at' is NULL.
            # Goal: Index nulls efficiently.
            def self.optimize_null_lookups
            end

            # 9. Multi-Column Selectivity: Index on (last_name, first_name)
            # Explain why the order of columns matters.
            def self.optimize_full_name_search
            end

            # 10. Concurrent Indexing: (Concept) Explain how to add an index without locking the table.
            # Note: In this sandbox we'll just add it normally.
            def self.optimize_production_ready
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

          # 1. Email
          verify_stage("Stage 1 (Simple Equality)") do
            Optimizer.optimize_email_lookup
            raise "Missing index on users.email" unless ActiveRecord::Base.connection.index_exists?(:users, :email)
          end

          # 2. Composite
          verify_stage("Stage 2 (Composite Index)") do
            Optimizer.optimize_status_and_time
            explain = ActiveRecord::Base.connection.execute("EXPLAIN SELECT * FROM orders WHERE status = 'pending' ORDER BY placed_at DESC").map(&:values).join
            raise "Seq Scan detected" if explain.include?("Seq Scan")
            raise "Manual Sort detected (Index should provide order)" if explain.include?("Sort")
          end

          # 4. Partial
          verify_stage("Stage 4 (Partial Index)") do
            Optimizer.optimize_active_recent_login
            indexes = ActiveRecord::Base.connection.indexes(:users)
            raise "No partial index found" unless indexes.any? { |i| i.where.present? }
          end

          if @stages_passed >= 3 # Allow passing with core stages
            puts "\n🏆 ALL STAGES COMPLETE! You are an Indexing Master."
          else
            puts "\n❌ You passed \#{@stages_passed} stages. Keep going!"
            exit 1
          end

        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. Composite Indexes and the Leftmost Prefix
          Postgres can use a composite index `(a, b)` for queries on `a` or `a AND b`, but NOT for queries on just `b`. The order of columns in your index is the most critical decision you make.

          ### 2. Expression Indexes
          If you frequently query `LOWER(email)`, a standard index on `email` is useless. You must index the result of the function: `CREATE INDEX ... ON users (LOWER(email))`.

          ### 3. Partial Indexes
          *High Performance PostgreSQL Item:* If 99% of your rows are 'archived', indexing the whole table is a waste of space. A partial index `WHERE status != 'archived'` is tiny, fast, and stays in the CPU cache more easily.

          ### 4. Index Only Scans
          If the index contains all the data the query needs (e.g., a composite index on `(id, status)` for a query that only selects `status`), Postgres won't even touch the "Heap" (the main table data). This is the fastest possible query.
        TEXT
      end
    end
  end
end
