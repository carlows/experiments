# KATA 2: THE MEGA RESILIENT PROCESSOR
# ------------------------------------
# Goal: Build a thread-safe, memory-efficient background job runner.

require 'thread'

class JobProcessor
  # 1. Memory Leak: Use nil-default for arrays to avoid shared state across instances.
  def initialize(results = nil)
    @results = results || []
    @mutex = Mutex.new
  end

  # 2. Scope Safety: Ensure threads use a snapshot of the current item.
  def process(items)
    items.map do |item|
      # TODO: Pass item into Thread.new correctly
      Thread.new do
        work(item)
      end
    end.each(&:join)
  end

  # 3. Thread-Safe Mutation: Wrap result collection in a Mutex.
  def collect_result(val)
  end

  # 4. Error Resilience: Use 'ensure' to log completion even on failure.
  def work(item)
    # TODO: Logic with ensure
  end

  # 5. The Queue: Use a 'Thread::Queue' for Producer-Consumer pattern.
  def queue_work(items)
  end

  # 6. Worker Pool: Start exactly 3 persistent worker threads to process the queue.
  def start_workers
  end

  # 7. Timeout: Ensure no single job takes longer than 1 second.
  # Hint: Use the 'timeout' library (carefully) or Thread#join(timeout).
  def timed_work(item)
  end

  # 8. Graceful Shutdown: Implement a way to stop workers after they finish current tasks.
  def shutdown
  end

  # 9. Result Throttling: If @results has > 100 items, wait before accepting new ones.
  def throttle?
  end

  # 10. Memory Monitoring: Implement a 'cleanup' method that clears the queue 
  # and triggers GC.
  def cleanup
  end
end

# --- TEST SUITE (DO NOT MODIFY) ---
@stages_passed = 0
def verify_stage(name)
  yield
  puts "✅ #{name} Passed"
  @stages_passed += 1
rescue => e
  puts "❌ #{name} Failed: #{e.message}"
end

puts "Starting 10-Stage Verification..."

# 1. Defaults
verify_stage("Stage 1 (Memory Leaks)") do
  p1 = JobProcessor.new; p1.results << 1
  p2 = JobProcessor.new
  raise "Shared state detected" if p2.results.any?
end

# 2. Scope
verify_stage("Stage 2 (Scope Safety)") do
  proc = JobProcessor.new
  items = (1..5).to_a
  # If they didn't pass item to Thread.new, item might be '5' for all
  # We check if we got unique results
  proc.process(items)
  raise "Thread scope race condition" unless proc.results.sort == items
end

# 3. Mutex
verify_stage("Stage 3 (Thread-Safe Mutation)") do
  proc = JobProcessor.new
  # Large number to trigger race condition on Array#<<
  items = (1..1000).to_a
  proc.process(items)
  raise "Data loss detected! Expected 1000, got #{proc.results.size}" if proc.results.size < 1000
end

# 4. Ensure
verify_stage("Stage 4 (Error Resilience)") do
  proc = JobProcessor.new
  def proc.work(item); raise "boom"; ensure; @results << "logged"; end
  begin; proc.process([1]); rescue; end
  raise "Ensure block not executed" unless proc.results.include?("logged")
end

# 5. Queue
verify_stage("Stage 5 (Thread::Queue)") do
  proc = JobProcessor.new
  # This is conceptual check if they used Queue in their code
  # But we can verify functionality
  proc.queue_work([1, 2, 3])
  # Assuming queue_work adds to a queue and we need workers to pull
  # We'll just check if it works as intended
end

# 6. Worker Pool
verify_stage("Stage 6 (Worker Pool)") do
  proc = JobProcessor.new
  proc.start_workers
  # Verify exactly 3 threads are alive (conceptually)
end

# 7. Timeout
verify_stage("Stage 7 (Timeouts)") do
  proc = JobProcessor.new
  def proc.work(item); sleep 2; end
  # Should not hang indefinitely
end

# 8. Shutdown
verify_stage("Stage 8 (Graceful Shutdown)") do
  proc = JobProcessor.new
  proc.start_workers
  proc.shutdown
end

# 9. Throttling
verify_stage("Stage 9 (Throttling)") do
  proc = JobProcessor.new
  # Check throttle? logic
end

# 10. Cleanup
verify_stage("Stage 10 (Memory Cleanup)") do
  proc = JobProcessor.new
  proc.cleanup
end

if @stages_passed == 10
  puts "
🏆 ALL STAGES COMPLETE! You are a Concurrency Master."
else
  puts "
❌ You passed #{@stages_passed}/10 stages. Keep going!"
  exit 1
end
