require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class WindowFunctions < RailsChallenge
      def initialize
        super('The Leaderboard (10-Stage Analytics)', '06_window_functions.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :employees, force: true do |t|
            t.string :name
            t.string :department
            t.integer :salary
            t.datetime :hired_on
          end
        end
      end

      def seed_data
        [
          ['Alice', 'Eng', 100, 1.year.ago], ['Bob', 'Eng', 90, 2.years.ago],
          ['Charlie', 'Eng', 110, 6.months.ago], ['Dave', 'Eng', 95, 3.years.ago],
          ['Eve', 'Sales', 80, 1.month.ago], ['Frank', 'Sales', 85, 4.years.ago],
          ['Grace', 'Sales', 70, 5.years.ago], ['Heidi', 'Sales', 85, 1.year.ago]
        ].each { |n, d, s, h| Employee.create!(name: n, department: d, salary: s, hired_on: h) }
      end

      def write_kata_file
        content = <<~RUBY
          class Employee < ActiveRecord::Base; end

          # --- YOUR MISSION ---
          # Master SQL Window functions for advanced reporting.

          class Reporting
            # 1. Simple Rank: Rank all employees by salary (highest first)
            def self.salary_ranking
            end

            # 2. Partitioned Rank: Rank employees by salary WITHIN their department.
            def self.dept_ranking
            end

            # 3. Handling Ties: Use DENSE_RANK() so ties don't skip numbers.
            def self.dense_salary_ranking
            end

            # 4. Row Numbers: Assign a unique sequential number to each employee by hire date.
            def self.hire_sequence
            end

            # 5. Top N: Return the top 2 highest-paid employees per department.
            def self.top_two_per_dept
            end

            # 6. Running Total: Calculate a running sum of salaries across the whole company.
            def self.payroll_growth
            end

            # 7. Lead/Lag: For each employee, find the salary of the person hired immediately BEFORE them.
            def self.previous_hire_salary
            end

            # 8. Percentile: Find the percentile rank (0.0 to 1.0) of each employee's salary.
            def self.salary_percentiles
            end

            # 9. Moving Average: Calculate a 3-person moving average of salary (current + 2 previous).
            def self.salary_moving_avg
            end

            # 10. Frame Clauses: Find the highest salary in the department SO FAR (up to the current hire).
            def self.max_salary_to_date
            end
          end

          # --- TEST SUITE ---
          puts "Starting 10-Stage Verification..."

          # 2. Dept Rank
          res = Reporting.dept_ranking
          charlie = res.find { |e| e.name == "Charlie" }
          raise "Ex 2 Failed" unless charlie.rank.to_i == 1
          puts "✅ Ex 2 Passed"

          # 3. Dense Rank
          # Frank and Heidi both have 85.
          res = Reporting.dense_salary_ranking
          frank = res.find { |e| e.name == "Frank" }
          heidi = res.find { |e| e.name == "Heidi" }
          raise "Ex 3 Failed: Ties should have same rank" unless frank.rank == heidi.rank
          puts "✅ Ex 3 Passed"

          # 5. Top 2
          res = Reporting.top_two_per_dept
          eng_count = res.select { |e| e.department == "Eng" }.count
          raise "Ex 5 Failed" unless eng_count == 2
          puts "✅ Ex 5 Passed"

          # 7. Lag
          res = Reporting.previous_hire_salary
          # Grace was 5y ago (70), Frank was 4y ago (85)
          frank = res.find { |e| e.name == "Frank" }
          raise "Ex 7 Failed" unless frank.prev_salary.to_i == 70
          puts "✅ Ex 7 Passed"

          puts "🏆 ALL STAGES COMPLETE!"
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `OVER (PARTITION BY ...)`
          This is the "Group By" of window functions. It defines the "window" of rows the function will look at. Unlike `GROUP BY`, it doesn't collapse the rows.

          ### 2. `RANK` vs `DENSE_RANK` vs `ROW_NUMBER`
          - `ROW_NUMBER`: Always unique (1, 2, 3, 4).
          - `RANK`: Ties get same number, next number is skipped (1, 2, 2, 4).
          - `DENSE_RANK`: Ties get same number, next number is NOT skipped (1, 2, 2, 3).

          ### 3. `LAG` and `LEAD`
          These are incredibly useful for time-series data or comparison reports. They allow you to "peek" at the row before or after the current one without doing a self-join.

          ### 4. Frame Clauses (`ROWS BETWEEN ...`)
          Frame clauses allow you to define a moving window (e.g., "the last 3 rows" or "everything from the start of the partition up to here"). This is how you calculate moving averages or running totals.
        TEXT
      end
    end
  end
end

class Employee < ActiveRecord::Base; end
