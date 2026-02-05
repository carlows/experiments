require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class TreeWalker < RailsChallenge
      def initialize
        super('The Tree Walker (Recursive CTEs)', '08_tree_walker.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :comments, force: true do |t|
            t.string :content
            t.integer :parent_id
          end
        end
      end

      def seed_data
        root = Comment.create!(content: 'Root')
        child1 = Comment.create!(content: 'C1', parent_id: root.id)
        Comment.create!(content: 'C2', parent_id: root.id)
        Comment.create!(content: 'GC1', parent_id: child1.id)
      end

      def write_kata_file
        content = <<~RUBY
          class Comment < ActiveRecord::Base; end

          # --- YOUR TASK ---
          # Fetch all comments in a single query, including a 'depth' column#{' '}
          # indicating how far down the tree they are.
          # You MUST use a 'WITH RECURSIVE' Common Table Expression (CTE).

          class CommentLoader
            def self.all_with_depth
              sql = <<~SQL
                WITH RECURSIVE comment_tree AS (
                  -- TODO: Base case (root comments)
                  -- UNION ALL
                  -- TODO: Recursive case
                )
                SELECT * FROM comment_tree
              SQL
              Comment.find_by_sql(sql)
            end
          end

          # --- TEST SUITE ---
          comments = CommentLoader.all_with_depth

          root = comments.find { |c| c.content == "Root" }
          gc1 = comments.find { |c| c.content == "GC1" }

          raise "CTE failed: missing comments" unless root && gc1
          raise "CTE failed: depth mismatch" unless root.depth.to_i == 0 && gc1.depth.to_i == 2

          puts "✅ Recursive CTE executed successfully"
          puts "✨ KATA COMPLETE!"
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. Recursive CTEs
          When data is hierarchical (like a file system or comment threads), you can't easily fetch it with a simple `JOIN` because you don't know the maximum depth. `WITH RECURSIVE` allows a query to refer to its own output.

          ### 2. Base Case vs Recursive Case
          - **Base Case:** The initial query that finds the starting points (e.g., all comments with `parent_id IS NULL`).
          - **Recursive Case:** Joins the previous result set back to the table to find the next level of children.

          ### 3. Closure Tree Gem
          In a production Rails app, you'd likely use a gem like `ancestry` or `closure_tree`. However, knowing the raw SQL for a CTE is a superpower for data scientists and DBAs.
        TEXT
      end
    end
  end
end

class Comment < ActiveRecord::Base; end
