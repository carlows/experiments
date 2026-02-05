require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class BulkImporter < RailsChallenge
      def initialize
        super('The Bulk Importer (10-Stage Throughput)', '09_bulk_importer.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :inventory, force: true do |t|
            t.string :sku, index: { unique: true }
            t.integer :quantity, default: 0
            t.decimal :price
            t.datetime :updated_at
            t.datetime :created_at
          end
        end
      end

      def seed_data
        Inventory.create!(sku: 'A1', quantity: 10, price: 100.0)
      end

      def write_kata_file
        content = <<~RUBY
          class Inventory < ActiveRecord::Base; end

          # --- YOUR MISSION ---
          # Master high-speed data ingestion.

          class Importer
            # 1. Bulk Insert: Use 'insert_all' to add 5 new SKUs in ONE query.
            def self.bulk_add(data)
            end

            # 2. Upsert: Use 'upsert_all' to update stock for A1 and add B2.
            # Handle the 'sku' unique constraint conflict.
            def self.sync_stock(data)
            end

            # 3. Partial Update: Use 'upsert_all' but ONLY update 'quantity',#{' '}
            # preserving the original 'price'.
            # Hint: Use the 'update_only' option.
            def self.update_stock_only(data)
            end

            # 4. Timestamps: insert_all doesn't set timestamps. Add them manually in the bulk hash.
            def self.add_with_timestamps(data)
            end

            # 5. On Conflict Do Nothing: Insert data but ignore any rows that already exist.
            def self.safe_import(data)
            end

            # 6. Bulk Plucking: Return an array of all SKUs using '.pluck'.
            def self.all_skus
            end

            # 7. Validations: insert_all skips validations.#{' '}
            # Implement a 'pre_validate' check that removes hashes with quantity < 0#{' '}
            # before calling bulk insert.
            def self.valid_import(data)
            end

            # 8. Returning Data: Use 'insert_all!' (bang) to return the inserted records' IDs.
            def self.import_and_get_ids(data)
            end

            # 9. Duplicate Detection: Before importing, find which SKUs in the input#{' '}
            # already exist in the database.
            def self.find_existing(skus_array)
            end

            # 10. Memory Efficient Import: Given an array of 100k hashes,#{' '}
            # import them in batches of 5000 using 'insert_all'.
            def self.mega_import(large_data)
            end
          end

          # --- TEST SUITE ---
          puts "Starting 10-Stage Verification..."

          # 1. Bulk Insert
          c = Inventory.count
          Importer.bulk_add([
            { sku: "B1", price: 10 }, { sku: "B2", price: 10 },#{' '}
            { sku: "B3", price: 10 }, { sku: "B4", price: 10 }, { sku: "B5", price: 10 }
          ])
          raise "Ex 1 Failed" unless Inventory.count == c + 5
          puts "✅ Ex 1 Passed"

          # 2. Upsert
          Importer.sync_stock([{ sku: "A1", quantity: 50 }, { sku: "C1", quantity: 5 }])
          raise "Ex 2 Failed: A1 not updated" unless Inventory.find_by(sku: "A1").quantity == 50
          puts "✅ Ex 2 Passed"

          # 5. Safe Import
          Importer.safe_import([{ sku: "A1", quantity: 999 }])
          raise "Ex 5 Failed: A1 was updated but should have been ignored" if Inventory.find_by(sku: "A1").quantity == 999
          puts "✅ Ex 5 Passed"

          # 8. Returning IDs
          ids = Importer.import_and_get_ids([{ sku: "D1", price: 5 }])
          raise "Ex 8 Failed" unless ids.first.is_a?(Integer)
          puts "✅ Ex 8 Passed"

          puts "🏆 ALL STAGES COMPLETE!"
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. The Cost of ActiveRecord Objects
          Instantiating a Ruby object for every row is expensive. `insert_all` sends raw hashes directly to SQL, bypassing validations, callbacks, and object instantiation. This is the difference between an import taking 1 hour and taking 10 seconds.

          ### 2. `ON CONFLICT` (Upsert)
          `upsert_all` translates to Postgres `INSERT ... ON CONFLICT (unique_column) DO UPDATE`. It's the most efficient way to handle "Create or Update" logic at scale.

          ### 3. Trade-offs
          - **No Validations:** You must validate the hashes in Ruby before calling `insert_all`.
          - **No Callbacks:** `after_create` or `after_commit` hooks will not run.
          - **No Timestamps:** You must include `created_at` and `updated_at` in your hashes manually.

          ### 4. Bulk Methods
          - `insert_all`: Simple bulk insert.
          - `insert_all!`: Raises error on conflict.
          - `upsert_all`: Update on conflict.
        TEXT
      end
    end
  end
end

class Inventory < ActiveRecord::Base; end
