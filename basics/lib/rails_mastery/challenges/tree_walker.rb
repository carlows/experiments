require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class TreeWalker < RailsChallenge
      def initialize
        super('The Tree Walker (10-Stage Recursion)', '08_tree_walker.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :nodes, force: true do |t|
            t.string :name
            t.integer :parent_id
            t.integer :value, default: 0
          end
        end
      end

      def seed_data
        root = Node.create!(name: 'Root', value: 100)
        c1 = Node.create!(name: 'C1', parent_id: root.id, value: 50)
        Node.create!(name: 'C2', parent_id: root.id, value: 30)
        Node.create!(name: 'GC1', parent_id: c1.id, value: 10)
        Node.create!(name: 'GC2', parent_id: c1.id, value: 20)
      end

      def write_kata_file
        content = <<~RUBY
          class Node < ActiveRecord::Base; end

          # --- YOUR MISSION ---
          # Master hierarchical data with Recursive CTEs.

          class Hierarchy
            # 1. Fetch All: Return all nodes with their 'depth' (Root = 0).
            def self.with_depth
            end

            # 2. Path Finder: For a given node, return its ancestors as a string (e.g. "Root / C1 / GC1").
            def self.full_path(node_id)
            end

            # 3. Subtree Sum: For each node, calculate the sum of 'value' for its entire subtree (including itself).
            def self.subtree_totals
            end

            # 4. Leaf nodes: Find all nodes that have NO children.
            def self.leaves
            end

            # 5. Node siblings: Find all nodes that share the same parent as the given node.
            def self.siblings(node_id)
            end

            # 6. Cycle detection: (Concept) Explain how to prevent infinite recursion in a CTE.
            # In this kata, just return the node's name if it would cause a cycle.
            def self.detect_cycles
            end

            # 7. Level Ordering: Fetch nodes ordered by depth, then by name.
            def self.breadth_first
            end

            # 8. Descendant Count: For each node, count how many total descendants it has.
            def self.count_descendants
            end

            # 9. Tree Pruning: Return the relation excluding a specific subtree (node + all descendants).
            def self.exclude_subtree(node_id)
            end

            # 10. Materialized Path: (Concept) Generate an 'LPATH' string for every node (e.g. "1.2.4").
            def self.generate_ids_path
            end
          end

          # --- TEST SUITE (DO NOT MODIFY) ---
          @stages_passed = 0
          def verify_stage(name)
            yield
            puts "✅ \#{name} Passed"
            @stages_passed += 1
          rescue => e
            puts "❌ \#{name} Failed: \#{e.message}"
          end

          puts "Starting 10-Stage Verification..."

          # 1. Depth
          verify_stage("Stage 1 (Recursive Depth)") do
            res = Hierarchy.with_depth
            gc1 = res.find { |n| n.name == "GC1" }
            raise "GC1 depth mismatch" unless gc1&.depth.to_i == 2
          end

          # 3. Sums
          verify_stage("Stage 3 (Subtree Sums)") do
            res = Hierarchy.subtree_totals
            root = res.find { |n| n.name == "Root" }
            raise "Root subtree sum mismatch" unless root&.total_value.to_i == 210
          end

          # 8. Count
          verify_stage("Stage 8 (Descendant Count)") do
            res = Hierarchy.count_descendants
            c1 = res.find { |n| n.name == "C1" }
            raise "C1 descendant count mismatch" unless c1&.descendant_count.to_i == 2
          end

          if @stages_passed >= 3
            puts "\n🏆 ALL STAGES COMPLETE! You are a Recursion Master."
          else
            puts "\n❌ You passed \#{@stages_passed} stages. Keep going!"
            exit 1
          end
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `WITH RECURSIVE`
          The backbone of hierarchical SQL. It allows you to traverse parent-child relationships of unknown depth in a single query.

          ### 2. Aggregating Hierarchies
          To calculate subtree sums or descendant counts, you typically use the CTE to "expand" the tree into a flat list of `(ancestor_id, descendant_id)` pairs, and then group by the ancestor.

          ### 3. Cycle Detection
          *Expert Tip:* Use `CYCLE` clause (in newer Postgres) or keep an array of visited IDs: `ARRAY[id]`. If `id = ANY(path)`, you've hit a loop.

          ### 4. Other Strategies
          - **Adjacency List:** What we used here (`parent_id`). Simple but requires CTEs.
          - **Materialized Path:** Store the path as a string (`/1/2/4`). Very fast for subtree fetching.
          - **Nested Sets:** Extremely fast for reads, but very slow/complex for writes.
        TEXT
      end
    end
  end
end

class Node < ActiveRecord::Base; end
