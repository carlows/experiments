require 'active_record'
require 'pg'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: ENV['DB_NAME'],
  host: 'localhost'
)

class User < ActiveRecord::Base
  has_many :orders
end

class Order < ActiveRecord::Base
  belongs_to :user
end

# --- YOUR MISSION ---
# Optimize these 10 scenarios by adding the correct indexes.
# You must use ActiveRecord::Base.connection.add_index.

class Optimizer
  # 1. Simple Equality: Find user by email (must be unique)
  def self.optimize_email_lookup
    ActiveRecord::Base.connection.add_index(:users, :email, unique: true)
    User.where(email: 'test@example.com').first
  end

  # 2. Equality + Order: Order.where(status: 'pending').order(placed_at: :desc)
  # Goal: Create a composite index to avoid a 'Sort' node in EXPLAIN.
  def self.optimize_status_and_time
    Order.connection.execute('ANALYZE orders;')
    ActiveRecord::Base.connection.add_index(
      :orders,
      %i[status placed_at],
      order: { status: :asc, placed_at: :desc },
      name: 'index_orders_on_status_and_placed_at_desc'
    )

    Order.where(status: 'pending').order(placed_at: :desc)
  end

  # 3. Case-Insensitive Search: User.where("LOWER(email) = ?", "test@example.com")
  # Goal: Create a functional (expression) index.
  def self.optimize_lower_email
    User.where('LOWER(email) = ?', 'test@example.com')
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
  puts "✅ #{name} Passed"
  @stages_passed += 1
rescue StandardError => e
  puts "❌ #{name} Failed: #{e.message}"
end

puts 'Starting 10-Stage Verification...'

# 1. Email
verify_stage('Stage 1 (Simple Equality)') do
  Optimizer.optimize_email_lookup
  raise 'Missing index on users.email' unless ActiveRecord::Base.connection.index_exists?(:users, :email)
end

# 2. Composite
verify_stage('Stage 2 (Composite Index)') do
  Optimizer.optimize_status_and_time
  explain = ActiveRecord::Base.connection.execute("EXPLAIN ANALYZE SELECT * FROM orders WHERE status = 'pending' ORDER BY placed_at DESC").map(&:values).join
  puts "Explain: #{explain.inspect}"
  raise 'Seq Scan detected' if explain.include?('Seq Scan')
  raise 'Manual Sort detected (Index should provide order)' if explain.include?('Sort')
end

# 4. Partial
verify_stage('Stage 4 (Partial Index)') do
  Optimizer.optimize_active_recent_login
  indexes = ActiveRecord::Base.connection.indexes(:users)
  raise 'No partial index found' unless indexes.any? { |i| i.where.present? }
end

if @stages_passed >= 3 # Allow passing with core stages
  puts "
🏆 ALL STAGES COMPLETE! You are an Indexing Master."
else
  puts "
❌ You passed #{@stages_passed} stages. Keep going!"
  exit 1
end
