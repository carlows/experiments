require_relative '../rails_challenge'
require 'faker'

module RailsMastery
  module Challenges
    class NPlusOneAssassin < RailsChallenge
      def initialize
        super('The N+1 Assassin (10-Stage Mastery)', '02_n_plus_one.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :authors, force: true do |t|
            t.string :name
          end

          create_table :books, force: true do |t|
            t.string :title
            t.integer :author_id
            t.integer :price
            t.integer :reviews_count, default: 0
          end

          create_table :reviews, force: true do |t|
            t.string :content
            t.integer :book_id
          end

          create_table :images, force: true do |t|
            t.string :url
            t.integer :imageable_id
            t.string :imageable_type
          end
        end
      end

      def seed_data
        # Ensure we have a variety of prices for conditional loading
        10.times do |i|
          author = Author.create!(name: Faker::Name.name)
          Image.create!(url: "author_#{i}.jpg", imageable: author)
          3.times do |j|
            # Ensure at least one cheap book (< 100) and one expensive book per author if possible
            price = j == 0 ? 50 : 200 + (j * 10)
            book = Book.create!(title: "Book #{i}-#{j} #{Faker::Book.title}", author: author, price: price)
            Image.create!(url: "book_#{i}_#{j}.jpg", imageable: book)
            2.times { Review.create!(content: "Review for #{book.title}", book: book) }
          end
        end
      end

      def write_kata_file
        content = <<~RUBY
          class Author < ActiveRecord::Base
            has_many :books
            has_one :image, as: :imageable
          end

          class Book < ActiveRecord::Base
            belongs_to :author
            has_many :reviews
            has_one :image, as: :imageable
          #{'  '}
            scope :cheap, -> { where("price < 100") }
          end

          class Review < ActiveRecord::Base
            # Requirement for Stage 7: Add counter_cache: true here
            belongs_to :book
          end

          class Image < ActiveRecord::Base
            belongs_to :imageable, polymorphic: true
          end

          # --- YOUR MISSION ---
          # Eliminate N+1 queries in these 10 distinct scenarios.

          class BookReport
            # 1. Basic: Fetch authors and their books (2 queries)
            def self.authors_with_books
              # TODO
            end

            # 2. Nested: Fetch authors, books, and reviews (3 queries)
            def self.authors_books_reviews
              # TODO
            end

            # 3. Polymorphic: Fetch authors and their images (2 queries)
            def self.authors_with_images
              # TODO
            end

            # 4. Deep Polymorphic: Fetch authors, books, and ALL their images (4 queries)
            def self.everything_with_images
              # TODO
            end

            # 5. Conditional Eager Loading: Fetch authors and only their 'cheap' books (< 100)
            # Hint: use Author.includes(:books).where(books: { price: 0..99 })#{' '}
            # OR a scoped association if you are feeling expert.
            def self.authors_with_cheap_books
              # TODO
            end

            # 6. Preload with Scope: Use Author.all but ensure books are loaded with title order.
            def self.authors_with_sorted_books
              # TODO
            end

            # 7. Counter Cache: Fix N+1 when calling book.reviews.size (0 extra queries)
            # You must use the 'reviews_count' column. Ensure 'counter_cache: true'#{' '}
            # is added to the Review model above.
            def self.books_with_review_count
              # TODO
            end

            # 8. Strict Loading: Return Author.all but with strict loading enabled.
            # This is to prove you know how to prevent N+1s in production.
            def self.enforce_strict_loading
              # TODO
            end

            # 9. Selective Eager Loading: Use 'eager_load' to filter authors who#{' '}
            # have a book containing 'Ruby' in the title. (1 query with JOIN)
            def self.authors_of_ruby_books
              # TODO
            end

            # 10. Manual Preloading: Use ActiveRecord::Associations::Preloader#{' '}
            # to load books onto an existing array of authors.
            def self.manual_preload(authors_array)
              # TODO
            end
          end

          # --- TEST SUITE (DO NOT MODIFY) ---
          def count_queries(&block)
            count = 0
            subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
              event = ActiveSupport::Notifications::Event.new(*args)
              count += 1 unless event.payload[:name] == "SCHEMA" || event.payload[:sql] =~ /BEGIN|COMMIT/
            end
            block.call
            ActiveSupport::Notifications.unsubscribe(subscriber)
            count
          end

          puts "Starting 10-Stage Verification..."

          # 1. Basic
          res = BookReport.authors_with_books
          raise "Ex 1 Failed: Returned nil or empty" if res.blank?
          c = count_queries { res.each { |a| a.books.to_a } }
          raise "Ex 1 Failed: Expected 2 queries (or 1 if joined), got \#{c}" if c > 2 || c == 0
          puts "✅ Ex 1 Passed"

          # 2. Nested
          res = BookReport.authors_books_reviews
          raise "Ex 2 Failed: Returned nil or empty" if res.blank?
          c = count_queries { res.each { |a| a.books.each { |b| b.reviews.to_a } } }
          raise "Ex 2 Failed: Expected 3 queries, got \#{c}" if c > 3 || c == 0
          puts "✅ Ex 2 Passed"

          # 3. Polymorphic
          res = BookReport.authors_with_images
          raise "Ex 3 Failed: Returned nil or empty" if res.blank?
          c = count_queries { res.each { |a| a.image } }
          raise "Ex 3 Failed: Expected 2 queries, got \#{c}" if c > 2 || c == 0
          puts "✅ Ex 3 Passed"

          # 4. Deep Polymorphic
          res = BookReport.everything_with_images
          raise "Ex 4 Failed: Returned nil or empty" if res.blank?
          c = count_queries { res.each { |a| a.image; a.books.each(&:image) } }
          raise "Ex 4 Failed: Expected 4 queries, got \#{c}" if c > 4 || c == 0
          puts "✅ Ex 4 Passed"

          # 5. Conditional
          res = BookReport.authors_with_cheap_books
          raise "Ex 5 Failed: Returned nil or empty" if res.blank?
          c = count_queries { res.each { |a| a.books.each { |b| raise 'Ex 5 Failed: Not cheap' if b.price >= 100 } } }
          raise "Ex 5 Failed: Expected efficient loading, got \#{c} queries" if c > 2 || c == 0
          puts "✅ Ex 5 Passed"

          # 6. Sorted
          res = BookReport.authors_with_sorted_books
          raise "Ex 6 Failed: Returned nil or empty" if res.blank?
          c = count_queries { res.each { |a|#{' '}
            titles = a.books.map(&:title)
            raise "Ex 6 Failed: Not sorted" unless titles == titles.sort
          } }
          raise "Ex 6 Failed: N+1 detected (\#{c} queries)" if c > 2 || c == 0
          puts "✅ Ex 6 Passed"

          # 7. Counter Cache
          res = BookReport.books_with_review_count
          raise "Ex 7 Failed: Returned nil or empty" if res.blank?
          c = count_queries { res.each { |b| b.reviews.size } }
          raise "Ex 7 Failed: Hit the DB for count! (\#{c} queries). Did you add counter_cache: true?" if c > 1 || c == 0
          puts "✅ Ex 7 Passed"

          # 8. Strict Loading
          res = BookReport.enforce_strict_loading
          begin
            res.first.books.to_a
            raise "Ex 8 Failed: Strict loading not enforced"
          rescue ActiveRecord::StrictLoadingViolationError
            puts "✅ Ex 8 Passed"
          end

          # 9. eager_load
          # Create a specific Ruby book for testing
          ruby_author = Author.create!(name: "Matz")
          Book.create!(author: ruby_author, title: "The Ruby Way", price: 50)
          res = BookReport.authors_of_ruby_books
          raise "Ex 9 Failed: Matz not found" unless res.map(&:name).include?("Matz")
          c = count_queries { BookReport.authors_of_ruby_books }
          raise "Ex 9 Failed: Should be 1 query with JOIN, got \#{c}" if c != 1
          puts "✅ Ex 9 Passed"

          # 10. Manual Preload
          authors = Author.limit(5).to_a
          c = count_queries { BookReport.manual_preload(authors) }
          raise "Ex 10 Failed: Expected 1 query for manual preload, got \#{c}" if c != 1
          raise "Ex 10 Failed: Books not loaded onto objects" unless authors.first.association(:books).loaded?
          puts "✅ Ex 10 Passed"

          puts "\n🏆 ALL STAGES COMPLETE! You are a N+1 Assassin."
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `includes` vs `preload` vs `eager_load`
          - **`preload`**: Separate queries. Use for large associations where a JOIN would explode the result set.
          - **`eager_load`**: Single query with LEFT JOIN. Essential for `ORDER BY` or `WHERE` on associated columns.
          - **`includes`**: Smart mode. Uses `preload` unless a JOIN is required by a `where` or `order` clause.

          ### 2. Deep Nested Loading
          Hash syntax `includes(books: [:reviews, :image])` allows you to load an entire graph in a predictable number of queries.

          ### 3. Counter Cache (`Effective Rails Item 20`)
          For simple counts, `size` with a `counter_cache` is O(1) in terms of queries. This is significantly faster than `includes(:reviews).count`.

          ### 4. Strict Loading (Rails 6.1+)
          Enabling `strict_loading!` on a relation or model is the best "Proactive" way to ensure N+1 bugs never reach production. It turns a performance issue into a hard crash in your test suite, where it's easy to fix.

          ### 5. Manual Preloading
          Sometimes you have an array of objects from different sources. `ActiveRecord::Associations::Preloader.new(records: authors, associations: :books).call` allows you to load associations onto them after they've been instantiated.
        TEXT
      end
    end
  end
end

class Author < ActiveRecord::Base
  has_many :books
  has_one :image, as: :imageable
end

class Book < ActiveRecord::Base
  belongs_to :author
  has_many :reviews
  has_one :image, as: :imageable
end

class Review < ActiveRecord::Base; belongs_to :book; end

class Image < ActiveRecord::Base; belongs_to :imageable, polymorphic: true; end
