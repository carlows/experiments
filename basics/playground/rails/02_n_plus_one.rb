require 'active_record'
require 'pg'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: ENV['DB_NAME'],
  host: 'localhost'
)

class Author < ActiveRecord::Base
  has_many :books, strict_loading: true
  has_many :affordable_books, -> { where('books.price < 100') }, class_name: 'Book'
  has_one :image, as: :imageable
end

class Book < ActiveRecord::Base
  belongs_to :author
  has_many :reviews
  has_one :image, as: :imageable
end

class Review < ActiveRecord::Base
  belongs_to :book, counter_cache: true
end

class Image < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true
end

# --- YOUR MISSION ---
# Eliminate N+1 queries in these 10 distinct scenarios.

class BookReport
  def self.authors_with_books
    Author.includes(:books).all
  end

  # 2. Nested: Fetch authors, books, and reviews
  def self.authors_books_reviews
    Author.includes(books: [:reviews]).all
  end

  # 3. Polymorphic: Fetch authors and their images
  def self.authors_with_images
    Author.includes(:image).all
  end

  # 4. Multi-level Polymorphic: Fetch authors, books, and ALL their images
  def self.everything_with_images
    Author.includes(books: [:image], image: :imageable).all
  end

  # 5. Conditional Eager Loading: Fetch authors and only their 'affordable' books (< 100)
  # Hint: You might need to use a scope or a custom join
  def self.authors_with_cheap_books
    Author.includes(:affordable_books).all
  end

  # 6. Preload with Scope: Use the 'Author.all' but ensure books are loaded with a title order
  def self.authors_with_sorted_books
    Author.includes(:books).order(books: { title: :asc }).all
  end

  # 7. Counter Cache: Fix the N+1 when calling book.reviews.size
  # Requirement: Do NOT use .includes(:reviews). Use a counter cache column.
  # (The column 'reviews_count' already exists in the schema)
  def self.books_with_review_count
    Book.all
  end

  # 8. Strict Loading: Enable strict loading on a relation to catch N+1s early
  def self.fail_on_n_plus_one
    Author.all
  end

  # 9. Selective Eager Loading: Use 'eager_load' specifically to filter authors by book title
  def self.authors_by_book_title(title_part)
    Author.eager_load(:books).where(books: { title: title_part }).all
  end

  # 10. Manual Preloading: Use ActiveRecord::Associations::Preloader 
  # to load books onto an already existing array of authors.
  def self.manual_preload(authors_array)
    ActiveRecord::Associations::Preloader.new(records: authors_array, associations: :books).call
  end
end

# --- TEST SUITE ---
def count_queries(&block)
  count = 0
  ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    count += 1 unless event.payload[:name] == "SCHEMA" || event.payload[:sql] =~ /BEGIN|COMMIT/
  end
  block.call
  ActiveSupport::Notifications.unsubscribe("sql.active_record")
  count
end

puts "Starting 10-Stage Verification..."

# 1. Basic
c = count_queries { BookReport.authors_with_books&.each { |a| a.books.to_a } }
raise "Ex 1 Failed: #{c} queries" if c > 2
puts "✅ Ex 1 Passed"

# 2. Nested
c = count_queries { BookReport.authors_books_reviews&.each { |a| a.books.each { |b| b.reviews.to_a } } }
raise "Ex 2 Failed: #{c} queries" if c > 3
puts "✅ Ex 2 Passed"

# 3. Poly
c = count_queries { BookReport.authors_with_images&.each { |a| a.image } }
raise "Ex 3 Failed" if c > 2
puts "✅ Ex 3 Passed"

# 4. Deep Poly
c = count_queries { BookReport.everything_with_images&.each { |a| a.image; a.books.each(&:image) } }
raise "Ex 4 Failed" if c > 4
puts "✅ Ex 4 Passed"

# 5. Conditional Eager Loading: Fetch authors and only their 'affordable' books (< 100)
c = count_queries { BookReport.authors_with_cheap_books&.each { |a| a.affordable_books.to_a } }
raise "Ex 5 Failed" if c > 2
puts "✅ Ex 5 Passed"

# 6. Preload with Scope: Use the 'Author.all' but ensure books are loaded with a title order
c = count_queries { BookReport.authors_with_sorted_books&.each { |a| a.books.to_a } }
raise "Ex 6 Failed" if c > 2 || c == 0
puts "✅ Ex 6 Passed"

# 7. Counter Cache
# We check if it hits the DB for reviews
acc = Book.first
acc.reviews.to_a # clear
c = count_queries { BookReport.books_with_review_count&.each { |b| b.reviews.size } }
raise "Ex 7 Failed: Hit the DB for count! #{c} queries" if c > 1
puts "✅ Ex 7 Passed"

# 8. Strict Loading
strict_error = false
begin
  c = count_queries { BookReport.fail_on_n_plus_one&.each { |b| b.books.to_a } }
rescue ActiveRecord::StrictLoadingViolationError => e
  strict_error = true
end
raise "Ex 8 Failed: Expected an error" unless strict_error
puts "✅ Ex 8 Passed"

# 9. Selective Eager Loading
c = count_queries { BookReport.authors_by_book_title('The N+1 Assassin')&.each { |a| a.books.to_a } }
raise "Ex 9 Failed" if c > 2 || c == 0
puts "✅ Ex 9 Passed"

# 10. Manual
authors = Author.limit(5).to_a
c = count_queries { BookReport.manual_preload(authors) }
raise "Ex 10 Failed: Expected 1 query for books, got #{c}" if c != 1
raise "Ex 10 Failed: Books not loaded" unless authors.first.association(:books).loaded?
puts "✅ Ex 10 Passed"

puts "🏆 ALL STAGES COMPLETE!"
