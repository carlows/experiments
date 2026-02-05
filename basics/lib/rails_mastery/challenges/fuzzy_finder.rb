require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class FuzzyFinder < RailsChallenge
      def initialize
        super('The Fuzzy Finder (10-Stage Search)', '10_fuzzy_finder.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          begin
            execute 'CREATE EXTENSION IF NOT EXISTS pg_trgm'
            execute 'CREATE EXTENSION IF NOT EXISTS fuzzystrmatch'
          rescue StandardError
            puts 'Warning: Extensions not enabled. Some stages may fail.'
          end

          create_table :movies, force: true do |t|
            t.string :title
            t.text :description
          end
        end
      end

      def seed_data
        [
          'Inception', 'Interstellar', 'The Dark Knight', 'Dunkirk', 'Tenet',
          'The Prestige', 'Memento', 'Batman Begins', 'Following', 'Insomnia'
        ].each { |t| Movie.create!(title: t) }
      end

      def write_kata_file
        content = <<~RUBY
          class Movie < ActiveRecord::Base; end

          # --- YOUR MISSION ---
          # Implement a world-class search engine using Postgres text features.

          class MovieSearch
            # 1. Trigram Similarity: Find "Inception" from "Insept".
            # Use the '%' operator.
            def self.similar_to(query)
            end

            # 2. Performance: Add a GIST index using 'gist_trgm_ops'.
            def self.add_fuzzy_index
            end

            # 3. Distance: Find movies and sort them by how similar they are#{' '}
            # to the query using the '<->' operator.
            def self.ordered_by_similarity(query)
            end

            # 4. Strict Similarity: Find movies with a similarity score > 0.5.
            # Hint: use 'set_limit' or the similarity(a, b) function.
            def self.highly_similar(query)
            end

            # 5. Soundex: Find "Memento" using the 'soundex' function#{' '}
            # (Matches words that sound the same).
            def self.sounds_like(query)
            end

            # 6. Levenshtein: Find movies where the title is within 2 'edits' of the query.
            def self.near_edits(query, max_dist)
            end

            # 7. Full Text Search (FTS): Find movies containing "Dark"#{' '}
            # using 'to_tsvector' and 'to_tsquery'.
            def self.fts_search(query)
            end

            # 8. FTS Ranking: Sort FTS results by relevance using 'ts_rank'.
            def self.fts_ranked(query)
            end

            # 9. FTS Stemming: Ensure a search for "Banking" matches "Bank"#{' '}
            # (Postgres handles this in tsvector).
            def self.stemmed_search(query)
            end

            # 10. Multi-column FTS: Search across BOTH 'title' and 'description'#{' '}
            # with higher weight given to the title.
            def self.weighted_search(query)
            end
          end

          # --- TEST SUITE ---
          puts "Starting 10-Stage Verification..."

          # 1. Similarity
          res = MovieSearch.similar_to("Insept")
          raise "Ex 1 Failed" unless res&.map(&:title)&.include?("Inception")
          puts "✅ Ex 1 Passed"

          # 2. Index
          MovieSearch.add_fuzzy_index
          indexes = ActiveRecord::Base.connection.execute("SELECT indexdef FROM pg_indexes WHERE tablename = 'movies'").map(&:values).join
          raise "Ex 2 Failed" unless indexes.include?("gist_trgm_ops")
          puts "✅ Ex 2 Passed"

          # 5. Soundex
          res = MovieSearch.sounds_like("Mamanto")
          raise "Ex 5 Failed" unless res&.map(&:title)&.include?("Memento")
          puts "✅ Ex 5 Passed"

          # 7. FTS
          res = MovieSearch.fts_search("Dark")
          raise "Ex 7 Failed" unless res&.map(&:title)&.include?("The Dark Knight")
          puts "✅ Ex 7 Passed"

          puts "🏆 ALL STAGES COMPLETE!"
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. Trigrams vs FTS
          - **Trigrams (`pg_trgm`):** Great for typos and "near" matches. It works by breaking words into 3-letter chunks.
          - **Full Text Search (FTS):** Great for large documents and complex queries (AND, OR, NOT). It works by "stemming" words (reducing "running" to "run") and removing "stop words" (like "the" or "and").

          ### 2. Similarity vs Distance
          - `%`: Uses a global threshold (`pg_trgm.similarity_threshold`).
          - `<->`: Returns the distance (inverse of similarity). Perfect for `ORDER BY`.

          ### 3. Soundex and Levenshtein
          Provided by the `fuzzystrmatch` extension. Soundex is phonetics-based (English only), while Levenshtein is edit-distance based.

          ### 4. Ranking and Weighting
          FTS allows you to assign "Weights" (A, B, C, D) to different columns. You can make a match in the Title (Weight A) count much more than a match in the Description (Weight D).
        TEXT
      end
    end
  end
end

class Movie < ActiveRecord::Base; end
