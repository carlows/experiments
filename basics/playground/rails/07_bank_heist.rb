require 'active_record'
require 'pg'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: ENV['DB_NAME'],
  host: 'localhost'
)

# Silence logger for cleaner output, but you can enable it for debugging
# ActiveRecord::Base.logger = Logger.new(STDOUT)

class Account < ActiveRecord::Base; end

# --- YOUR TASK ---
# Implement a withdraw method that is THREAD-SAFE.
# If two threads try to withdraw $60 from a $100 account,
# only one should succeed, and the balance should never go negative.
#
# Use ActiveRecord's pessimistic locking (lock!).

class BankService
  def self.withdraw(account_id, amount)
    Account.transaction do
      account = Account.find(account_id)
      account.lock!

      if account.balance >= amount
        account.update!(balance: account.balance - amount)
      end
    end
  end
end

# --- TEST SUITE ---
account = Account.find_by(owner: "Victim")

account.balance = 100
account.save!

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
puts "Final Balance: #{final_balance}"

if final_balance < 0
  raise "Security Breach! Balance is negative: #{final_balance}"
elsif final_balance == 40
  puts "✅ Concurrency handled correctly"
else
  raise "Logic error: Balance should be 40"
end

puts "✨ KATA COMPLETE!"
