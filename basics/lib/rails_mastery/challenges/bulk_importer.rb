require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class BulkImporter < RailsChallenge
      def initialize
        super('The Bulk Importer (Upserts)', '09_bulk_importer.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :skus, force: true do |t|
            t.string :code, index: { unique: true }
            t.integer :stock
          end
        end
      end

      def seed_data
        Sku.create!(code: 'A1', stock: 10)
      end

      def write_kata_file
        content = <<~RUBY
          class Sku < ActiveRecord::Base; end

          # --- YOUR TASK ---
          # You have a list of new stock levels.#{' '}
          # Some SKUs already exist (A1), some are new (B2).
          # Use 'upsert_all' to import them in a single query.
          # If a SKU exists, update its stock. If not, insert it.

          class InventorySync
            def self.sync!(data)
              # data: [{ code: "A1", stock: 15 }, { code: "B2", stock: 5 }]
              # TODO: Use Sku.upsert_all
            end
          end

          # --- TEST SUITE ---
          query_count = 0
          ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
            query_count += 1 if args.last[:sql] =~ /INSERT/
          end

          InventorySync.sync!([{ code: "A1", stock: 15 }, { code: "B2", stock: 5 }])

          raise "Bulk Import failed: Expected 1 query, got \#{query_count}" if query_count > 1

          sku_a1 = Sku.find_by(code: "A1")
          raise "Upsert failed: A1 stock not updated" unless sku_a1.stock == 15

          sku_b2 = Sku.find_by(code: "B2")
          raise "Upsert failed: B2 not inserted" unless sku_b2&.stock == 5

          puts "✅ Bulk upsert completed in a single query"
          puts "✨ KATA COMPLETE!"
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `insert_all` and `upsert_all`
          Added in Rails 6, these methods bypass the standard ActiveRecord lifecycle (no callbacks, no validations) to perform bulk SQL operations. This is 100x faster than calling `.save` in a loop.

          ### 2. The Unique Constraint
          `upsert_all` relies on a unique index in Postgres. When a conflict occurs (i.e., you try to insert a code that already exists), Postgres's `ON CONFLICT` clause triggers an update instead of a crash.

          ### 3. Missing Callables
          Because `upsert_all` goes straight to SQL, `updated_at` and `created_at` are NOT automatically set unless you provide them in the hash. Also, `after_save` callbacks will not run. This is a tradeoff for extreme performance.
        TEXT
      end
    end
  end
end

class Sku < ActiveRecord::Base; end
