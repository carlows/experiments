require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class BankHeist < RailsChallenge
      def initialize
        super('The Bank Heist (Concurrency)', '07_bank_heist.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :accounts, force: true do |t|
            t.string :owner
            t.integer :balance
          end
        end
      end

      def seed_data
        Account.create!(owner: 'Victim', balance: 100)
      end

      def write_kata_file
        content = <<~RUBY
          class Account < ActiveRecord::Base; end

          # --- YOUR TASK ---
          # Implement a withdraw method that is THREAD-SAFE.
          # If two threads try to withdraw $60 from a $100 account,
          # only one should succeed, and the balance should never go negative.
          #
          # Use ActiveRecord's pessimistic locking (lock!).

          class BankService
            def self.withdraw(account_id, amount)
              # TODO: Find account, lock it, check balance, and update
            end
          end

          # --- TEST SUITE ---
          account = Account.find_by(owner: "Victim")

          # Simulation of a race condition
          threads = 2.times.map do
            Thread.new do
              begin
                BankService.withdraw(account.id, 60)
              rescue => e
                # One of them might fail with a balance error
              end
            end
          end
          threads.each(&:join)

          final_balance = Account.find(account.id).balance
          puts "Final Balance: \#{final_balance}"

          if final_balance < 0
            raise "Security Breach! Balance is negative: \#{final_balance}"
          elsif final_balance == 40
            puts "✅ Concurrency handled correctly"
          else
            raise "Logic error: Balance should be 40"
          end

          puts "✨ KATA COMPLETE!"
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. The Race Condition
          In a high-concurrency environment, two threads might read the balance of $100 at the same time. Both see that they can afford a $60 withdrawal, and both write back a new balance. Without locking, you end up with a "Double Spend" or a negative balance.

          ### 2. Pessimistic Locking (`lock!`)
          By calling `account.lock!`, ActiveRecord issues a `SELECT ... FOR UPDATE` query. Postgres will hold a lock on that specific row until the transaction is committed or rolled back. Any other thread trying to lock that same row will wait until the first one is done.

          ### 3. Optimistic Locking
          An alternative to pessimistic locking is adding a `lock_version` column to your table. Rails will automatically check if the version has changed since you read it. If it has, it raises an `ActiveRecord::StaleObjectError`. This is better for "Low Contention" scenarios.
        TEXT
      end
    end
  end
end

class Account < ActiveRecord::Base; end
