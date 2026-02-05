require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class FuzzyFinder < RailsChallenge
      def initialize
        super('The Fuzzy Finder (Trigrams)', '10_fuzzy_finder.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          # We need to enable the extension in the DB
          begin
            execute 'CREATE EXTENSION IF NOT EXISTS pg_trgm'
          rescue StandardError
            puts 'Warning: Could not enable pg_trgm. Ensure you have the contrib package installed.'
          end

          create_table :movies, force: true do |t|
            t.string :title
          end
          # TODO: You'll need to add a GIST or GIN index for trigrams in your solution
        end
      end

      def seed_data
        ['Inception', 'Interstellar', 'The Dark Knight', 'Dunkirk', 'Tenet'].each do |t|
          Movie.create!(title: t)
        end
      end

      def write_kata_file
        content = <<~RUBY
          class Movie < ActiveRecord::Base; end

          # --- YOUR TASK ---
          # Implement a fuzzy search that can find "Inception" even if#{' '}
          # the user types "Insept").
          # 1. Enable pg_trgm (if not enabled).
          # 2. Add a GIST index on 'title' using 'gist_trgm_ops'.
          # 3. Use the '%' operator in a WHERE clause.

          class MovieSearch
            def self.fuzzy(title_query)
              # TODO: Implement fuzzy search
              # Movie.where("title % ?", title_query)
            end
          end

          # --- TEST SUITE ---
          res = MovieSearch.fuzzy("Insept")
          raise "Fuzzy search failed: Could not find Inception from 'Insept'" unless res.map(&:title).include?("Inception")

          # Check for index
          idx_query = "SELECT indexdef FROM pg_indexes WHERE tablename = 'movies'"
          indexes = ActiveRecord::Base.connection.execute(idx_query).map { |r| r["indexdef"] }.join
          raise "Missing Index: Add a gist_trgm_ops index for performance" unless indexes.include?("gist_trgm_ops") || indexes.include?("gin_trgm_ops")

          puts "✅ Fuzzy search with Trigram index passed"
          puts "✨ KATA COMPLETE!"
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. Trigrams
          A trigram is a group of three consecutive characters taken from a string. By comparing the number of shared trigrams, Postgres can determine how similar two strings are.

          ### 2. `pg_trgm` Extension
          This extension provides the `%` operator (similarity check) and specialized index classes.

          ### 3. GiST and GIN for Trigrams
          - **GiST** (Generalized Search Tree): Good for fuzzy matching and nearest-neighbor searches.
          - **GIN** (Generalized Inverted Index): Usually faster for searches but slower to build.
          Using `gist_trgm_ops` allows your fuzzy search to bypass Sequential Scans, which is vital for large text datasets.
        TEXT
      end
    end
  end
end

class Movie < ActiveRecord::Base; end
