require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class JsonbSearch < RailsChallenge
      def initialize
        super('The JSONB Search (GIN Indexes)', '05_jsonb_search.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          # Postgres JSONB support
          enable_extension 'plpgsql'
          create_table :events, force: true do |t|
            t.string :name
            t.jsonb :payload, default: {}
          end
        end
      end

      def seed_data
        Event.create!(name: 'click', payload: { 'browser' => 'Chrome', 'os' => 'macOS' })
        Event.create!(name: 'hover', payload: { 'browser' => 'Firefox', 'os' => 'Windows' })
      end

      def write_kata_file
        content = <<~RUBY
          class Event < ActiveRecord::Base; end

          # --- YOUR TASK ---
          # 1. Add a GIN index to the 'payload' column to speed up searches.
          # 2. Implement a search method that uses the '@>' (containment) operator.

          class EventSearch
            def self.by_browser(browser_name)
              # TODO: Use raw SQL with the containment operator for performance
              # Event.where("payload @> ?", { browser: browser_name }.to_json)
            end
          end

          # --- TEST SUITE ---
          # 1. Verification of index
          indexes = ActiveRecord::Base.connection.indexes(:events)
          gin_index = indexes.find { |i| i.using == :gin }
          raise "Missing Index: Add a GIN index to 'payload'" unless gin_index
          puts "✅ GIN index detected"

          # 2. Search test
          res = EventSearch.by_browser("Chrome")
          raise "Search failed" unless res.count == 1 && res.first.payload["os"] == "macOS"
          puts "✅ JSONB search works"

          puts "✨ KATA COMPLETE!"
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. JSON vs JSONB
          - `JSON` stores data as plain text. Every time you query it, Postgres has to parse it.
          - `JSONB` stores data in a binary format. It's slower to write but significantly faster to query and supports indexing.

          ### 2. GIN Indexes (Generalized Inverted Index)
          B-Trees are for sorting. GIN indexes are for "containment." They allow Postgres to index every key and value inside your JSONB blob, making queries like "Find all events where browser is Chrome" lightning fast.

          ### 3. The Containment Operator (`@>`)
          In ActiveRecord, you can use `where("payload ->> 'browser' = ?", 'Chrome')`, but this is often slow. The `@>` operator is "Smarter" and can utilize the GIN index effectively.
        TEXT
      end
    end
  end
end

class Event < ActiveRecord::Base; end
