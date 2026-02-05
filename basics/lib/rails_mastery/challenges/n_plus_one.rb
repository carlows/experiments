require_relative '../rails_challenge'

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
        10.times do
          author = Author.create!(name: Faker::Name.name)
          Image.create!(url: 'author.jpg', imageable: author)
          3.times do
            book = Book.create!(title: Faker::Book.title, author: author)
            Image.create!(url: 'book.jpg', imageable: book)
            2.times { Review.create!(content: 'Good', book: book) }
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
          end

          class Review < ActiveRecord::Base
            belongs_to :book
          end

          class Image < ActiveRecord::Base
            belongs_to :imageable, polymorphic: true
          end

          # --- YOUR MISSION ---
          # Eliminate N+1 queries in these 10 distinct scenarios.

          class BookReport
            # 1. Basic: Fetch authors and their books
            def self.authors_with_books
            end

            # 2. Nested: Fetch authors, books, and reviews
            def self.authors_books_reviews
            end

            # 3. Polymorphic: Fetch authors and their images
            def self.authors_with_images
            end

            # 4. Multi-level Polymorphic: Fetch authors, books, and ALL their images
            def self.everything_with_images
            end

            # 5. Conditional Eager Loading: Fetch authors and only their 'affordable' books (< 100)
            # Hint: You might need to use a scope or a custom join
            def self.authors_with_cheap_books
            end

            # 6. Preload with Scope: Use the 'Author.all' but ensure books are loaded with a title order
            def self.authors_with_sorted_books
            end

            # 7. Counter Cache: Fix the N+1 when calling book.reviews.size
            # Requirement: Do NOT use .includes(:reviews). Use a counter cache column.
            # (The column 'reviews_count' already exists in the schema)
            def self.books_with_review_count
            end

            # 8. Strict Loading: Enable strict loading on a relation to catch N+1s early
            def self.fail_on_n_plus_one
            end

            # 9. Selective Eager Loading: Use 'eager_load' specifically to filter authors by book title
            def self.authors_by_book_title(title_part)
            end

            # 10. Manual Preloading: Use ActiveRecord::Associations::Preloader#{' '}
            # to load books onto an already existing array of authors.
            def self.manual_preload(authors_array)
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
          raise "Ex 1 Failed: \#{c} queries" if c > 2
          puts "✅ Ex 1 Passed"

          # 2. Nested
          c = count_queries { BookReport.authors_books_reviews&.each { |a| a.books.each { |b| b.reviews.to_a } } }
          raise "Ex 2 Failed: \#{c} queries" if c > 3
          puts "✅ Ex 2 Passed"

          # 3. Poly
          c = count_queries { BookReport.authors_with_images&.each { |a| a.image } }
          raise "Ex 3 Failed" if c > 2
          puts "✅ Ex 3 Passed"

          # 4. Deep Poly
          c = count_queries { BookReport.everything_with_images&.each { |a| a.image; a.books.each(&:image) } }
          raise "Ex 4 Failed" if c > 4
          puts "✅ Ex 4 Passed"

          # 7. Counter Cache
          # We check if it hits the DB for reviews
          acc = Book.first
          acc.reviews.to_a # clear
          c = count_queries { BookReport.books_with_review_count&.each { |b| b.reviews.size } }
          raise "Ex 7 Failed: Hit the DB for count! \#{c} queries" if c > 1
          puts "✅ Ex 7 Passed"

          # 10. Manual
          authors = Author.limit(5).to_a
          c = count_queries { BookReport.manual_preload(authors) }
          raise "Ex 10 Failed: Expected 1 query for books, got \#{c}" if c != 1
          raise "Ex 10 Failed: Books not loaded" unless authors.first.association(:books).loaded?
          puts "✅ Ex 10 Passed"

          puts "🏆 ALL STAGES COMPLETE!"
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `includes` vs `preload` vs `eager_load`
          - **`preload`**: Separate queries. Best for large associations where a JOIN would create a massive result set.
          - **`eager_load`**: Single LEFT JOIN. Required if you want to filter (WHERE) or sort (ORDER) by columns in the association.
          - **`includes`**: The default choice. It chooses `preload` unless you force a JOIN.

          ### 2. Polymorphic Eager Loading
          Rails handles polymorphic associations seamlessly with `includes(:imageable)`. It will perform separate queries for each type of `imageable` object it finds.

          ### 3. Counter Caches
          *Effective Rails Item 20* - For simple counts, don't even use eager loading. A `counter_cache` column keeps the count on the parent record, reducing the "count query" to zero extra queries.

          ### 4. `Strict Loading`
          Introduced in Rails 6.1, `strict_loading!` is a great way to ensure your production code never accidentally introduces an N+1. It raises an error if you try to access an association that wasn't explicitly loaded.
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
