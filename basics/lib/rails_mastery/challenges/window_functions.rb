require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class WindowFunctions < RailsChallenge
      def initialize
        super('The Leaderboard (Window Functions)', '06_window_functions.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :employees, force: true do |t|
            t.string :name
            t.string :department
            t.integer :salary
          end
        end
      end

      def seed_data
        [
          ['Alice', 'Eng', 100], ['Bob', 'Eng', 90], ['Charlie', 'Eng', 110], ['Dave', 'Eng', 95],
          ['Eve', 'Sales', 80], ['Frank', 'Sales', 85], ['Grace', 'Sales', 70]
        ].each { |n, d, s| Employee.create!(name: n, department: d, salary: s) }
      end

      def write_kata_file
        content = <<~RUBY
          class Employee < ActiveRecord::Base; end

          # --- YOUR TASK ---
          # "Find the top 2 highest-paid employees per department."
          # You MUST use the SQL 'RANK()' or 'DENSE_RANK()' window function.
          # The result should be a collection of Employee objects, each having#{' '}
          # an extra attribute 'salary_rank'.

          class SalaryReport
            def self.top_two_per_dept
              # TODO: Implement using a subquery or CTE with RANK()
              # Employee.from(...)
            end
          end

          # --- TEST SUITE ---
          results = SalaryReport.top_two_per_dept

          eng_top = results.select { |e| e.department == "Eng" }.map(&:name)
          raise "Ranking failed for Eng: Expected Charlie and Alice" unless eng_top.include?("Charlie") && eng_top.include?("Alice")
          raise "Ranking failed: Too many results for Eng" if eng_top.size > 2

          puts "✅ Window function ranking passed"
          puts "✨ KATA COMPLETE!"
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. Window Functions (`OVER`)
          Standard aggregate functions (like `SUM`) collapse rows. Window functions perform a calculation across a set of rows that are related to the current row, but they keep the rows separate.

          ### 2. `RANK()` vs `DENSE_RANK()`
          - `RANK()`: If two people are tied for 1st, the next person is 3rd.
          - `DENSE_RANK()`: If two people are tied for 1st, the next person is 2nd.

          ### 3. ActiveRecord and Subqueries
          ActiveRecord doesn't have a native DSL for `RANK()`, so you often use `.from(subquery, :employees)`. This allows you to treat the output of a complex SQL query as if it were a standard table, giving you full access to ActiveRecord's object mapping.
        TEXT
      end
    end
  end
end

class Employee < ActiveRecord::Base; end
