require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class BankHeist < RailsChallenge
      def initialize
        super('The Mega Bank Heist (10-Stage Resilience)', '07_bank_heist.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :accounts, force: true do |t|
            t.string :owner
            t.integer :balance, default: 0
            t.integer :lock_version, default: 0
            t.integer :daily_limit, default: 100
            t.integer :withdrawn_today, default: 0
          end

          create_table :audit_logs, force: true do |t|
            t.integer :account_id
            t.string :action
            t.integer :amount
            t.datetime :created_at
          end
        end
      end

      def seed_data
        Account.create!(owner: 'Victim', balance: 1000, daily_limit: 500)
        Account.create!(owner: 'Recipient', balance: 0)
      end

      def write_kata_file
        content = <<~RUBY
          class Account < ActiveRecord::Base
            has_many :audit_logs
          end

          class AuditLog < ActiveRecord::Base
            belongs_to :account
          end

          # --- YOUR MISSION ---
          # You are the Lead Architect of a new Banking Core.#{' '}
          # You must implement these 10 features with absolute precision.

          class BankCore
            # EXERCISE 1: Basic Withdrawal
            # Ensure balance doesn't go negative. Raise an error if it does.
            def self.withdraw(account_id, amount)
              # TODO
            end

            # EXERCISE 2: Thread-Safe Withdrawal
            # Fix the "Double Spend" race condition using Pessimistic Locking (lock!).
            def self.safe_withdraw(account_id, amount)
              # TODO
            end

            # EXERCISE 3: Optimistic Deposits
            # Implement a deposit that uses 'lock_version' (Optimistic Locking).
            # If the update fails due to a stale object, retry once.
            def self.optimistic_deposit(account_id, amount)
              # TODO
            end

            # EXERCISE 4: Atomic Transfers
            # Move money from A to B. Ensure it's inside a transaction.
            # If B's deposit fails, A's withdrawal must roll back.
            def self.transfer(from_id, to_id, amount)
              # TODO
            end

            # EXERCISE 5: Deadlock Prevention
            # When transferring between two accounts, always lock them in a#{' '}
            # consistent order (e.g. by ID) to prevent circular deadlocks.
            def self.safe_transfer(from_id, to_id, amount)
              # TODO
            end

            # EXERCISE 6: Immutable Audit Logs
            # Every successful withdrawal MUST create an AuditLog entry.
            def self.withdraw_with_log(account_id, amount)
              # TODO
            end

            # EXERCISE 7: Daily Limit Race Condition
            # Check 'withdrawn_today' + amount <= 'daily_limit'.
            # Ensure this check is thread-safe!
            def self.limited_withdraw(account_id, amount)
              # TODO
            end

            # EXERCISE 8: Overdraft Protection with Fees
            # If balance < amount, instead of failing, allow it IF balance > -100
            # but apply a $20 'Overdraft Fee'.
            def self.overdraft_withdraw(account_id, amount)
              # TODO
            end

            # EXERCISE 9: Batch Interest Processing
            # Add 5% interest to ALL accounts with balance > 0.
            # Must be done in batches of 1000 for memory safety.
            def self.apply_interest
              # TODO
            end

            # EXERCISE 10: The Emergency Shutdown (Maintenance Mode)
            # Use a class variable or a global setting to prevent ANY#{' '}
            # transactions if 'MAINTENANCE_MODE' is true.
            def self.toggle_maintenance(value)
              @maintenance = value
            end
          end

          # --- TEST SUITE (DO NOT MODIFY) ---
          puts "Starting 10-Stage Verification..."

          # 1. Basic Withdrawal
          begin
            BankCore.withdraw(Account.first.id, 2000)
            raise "Ex 1 Failed: Allowed negative balance"
          rescue => e
            puts "✅ Ex 1 Passed"
          end

          # 2. Concurrency (Pessimistic)
          acc = Account.first
          acc.update!(balance: 100)
          threads = 2.times.map { Thread.new { begin; BankCore.safe_withdraw(acc.id, 60); rescue; end } }
          threads.each(&:join)
          raise "Ex 2 Failed: Race condition! Balance is \#{acc.reload.balance}" unless acc.reload.balance == 40
          puts "✅ Ex 2 Passed"

          # 3. Optimistic
          BankCore.optimistic_deposit(acc.id, 50)
          raise "Ex 3 Failed" unless acc.reload.balance == 90
          puts "✅ Ex 3 Passed"

          # 4 & 5. Safe Transfer
          acc2 = Account.last
          BankCore.safe_transfer(acc.id, acc2.id, 40)
          raise "Ex 4/5 Failed" unless acc.reload.balance == 50 && acc2.reload.balance == 40
          puts "✅ Ex 4/5 Passed"

          # 6. Audit Logs
          BankCore.withdraw_with_log(acc.id, 10)
          raise "Ex 6 Failed" unless AuditLog.where(account_id: acc.id).count > 0
          puts "✅ Ex 6 Passed"

          # 7. Daily Limit
          begin
            BankCore.limited_withdraw(acc.id, 600)
            raise "Ex 7 Failed: Exceeded daily limit"
          rescue
            puts "✅ Ex 7 Passed"
          end

          # 8. Overdraft
          acc.update!(balance: 10)
          BankCore.overdraft_withdraw(acc.id, 50)
          raise "Ex 8 Failed: Fee or Balance mismatch" unless acc.reload.balance == -60 # 10 - 50 - 20
          puts "✅ Ex 8 Passed"

          # 9. Batch Interest
          acc.update!(balance: 100)
          BankCore.apply_interest
          raise "Ex 9 Failed" unless acc.reload.balance == 105
          puts "✅ Ex 9 Passed"

          # 10. Maintenance
          BankCore.toggle_maintenance(true)
          begin
            BankCore.withdraw(acc.id, 1)
            raise "Ex 10 Failed: Allowed txn during maintenance"
          rescue
            puts "✅ Ex 10 Passed"
          end

          puts "🏆 ALL STAGES COMPLETE! You are a Financial Systems Architect."
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. Pessimistic Locking (`lock!`)
          Uses `SELECT ... FOR UPDATE` to block other transactions from reading/writing the row until your transaction ends.

          ### 2. Optimistic Locking (`lock_version`)
          *Effective Rails Practice:* Use this when conflicts are rare. It avoids DB-level locks, making it more scalable, but requires handling `ActiveRecord::StaleObjectError`.

          ### 3. Deadlock Prevention
          Deadlocks occur when Thread A locks Row 1 and wants Row 2, while Thread B locks Row 2 and wants Row 1. By sorting IDs (`[id1, id2].sort`), both threads will try to lock Row 1 first, forcing one to wait and avoiding the circular dependency.

          ### 4. Atomic Transactions
          `ActiveRecord::Base.transaction` ensures that if any part of the block fails (raises an exception), the entire set of changes is rolled back.

          ### 5. Batching (`find_each`)
          Applying interest to millions of accounts must be done in batches. `find_each` is the standard tool to keep memory usage low while processing the entire table.
        TEXT
      end
    end
  end
end
