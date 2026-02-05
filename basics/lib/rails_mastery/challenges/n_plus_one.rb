require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class NPlusOneAssassin < RailsChallenge
      def initialize
        super('The N+1 Assassin (Eager Loading)', '02_n_plus_one.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :authors, force: true do |t|
            t.string :name
          end

          create_table :books, force: true do |t|
            t.string :title
            t.integer :author_id
          end

          create_table :reviews, force: true do |t|
            t.string :content
            t.integer :book_id
          end
        end
      end

      def seed_data
        10.times do
          author = Author.create!(name: Faker::Name.name)
          3.times do
            book = Book.create!(title: Faker::Book.title, author: author)
            2.times { Review.create!(content: 'Good', book: book) }
          end
        end
      end

      def write_kata_file
        content = <<~RUBY
          class Author < ActiveRecord::Base
            has_many :books
          end

          class Book < ActiveRecord::Base
            belongs_to :author
            has_many :reviews
          end

          class Review < ActiveRecord::Base
            belongs_to :book
          end

          # --- YOUR TASK ---
          # Implement a report that fetches all authors, their books, and their books' reviews
          # with MINIMAL queries.
          # Use ActiveRecord's eager loading features.

          class BookReport
            def self.fetch_all
              # TODO: Optimize this to avoid N+1 queries for books and reviews
              Author.all
            end
          end

          # --- TEST SUITE ---
          query_count = 0
          ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
            event = ActiveSupport::Notifications::Event.new(*args)
            query_count += 1 unless event.payload[:name] == "SCHEMA" || event.payload[:sql] =~ /BEGIN|COMMIT/
          end

          authors = BookReport.fetch_all

          # Triggering the N+1 if not optimized
          authors.each do |a|
            a.books.each do |b|
              b.reviews.to_a
            end
          end

          puts "Total Queries: \#{query_count}"

          if query_count <= 3
            puts "✅ N+1 successfully avoided!"
          else
            raise "N+1 detected! Total queries: \#{query_count}. Expected <= 3."
          end

          puts "✨ KATA COMPLETE!"
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `includes` vs `preload` vs `eager_load`
          - **`preload`**: Uses separate SELECT queries. Generally more efficient for large datasets because it avoids a giant JOIN table.
          - **`eager_load`**: Uses a single LEFT OUTER JOIN. Necessary if you want to use `where` on the associated table's columns.
          - **`includes`**: Smart choice. It defaults to `preload` unless you use a `where` or `order` that references the association, in which case it switches to `eager_load`.

          ### 2. Nested Eager Loading
          You can load deep associations using hash syntax: `Author.includes(books: :reviews)`. This tells Rails to load authors, then all their books, then all reviews for those books in 3 efficient queries.

          ### 3. Bullet Gem
          In real Rails apps, the `bullet` gem is the best way to catch these in development. But as an expert, you should be able to spot them just by looking at the logs or using `ActiveSupport::Notifications` as we did in this test.
        TEXT
      end
    end
  end
end

class Author < ActiveRecord::Base; has_many :books; end

class Book < ActiveRecord::Base
  belongs_to :author
  has_many :reviews
end

class Review < ActiveRecord::Base; belongs_to :book; end
