require_relative '../challenge'

module RubyMastery
  module Challenges
    class ResilientProcessor < Challenge
      def initialize
        super('The Resilient Processor (Safety & Scope)', '02_resilient_processor.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 2: THE RESILIENT PROCESSOR
          # ------------------------------
          # This processor has several "Expert" bugs related to threading, memory, and scope.
          # Fix them to make the processor resilient.

          require 'thread'

          class JobProcessor
            attr_reader :results, :logs

            # BUG 1: The default arguments are mutable and shared across all instances!
            # Fix this so each instance gets its own empty array.
            def initialize(results = [], logs = [])
              @results = results
              @logs = logs
              @mutex = Mutex.new
            end

            def process(items)
              # BUG 2: Closure/Scope trap.#{' '}
              # In some Ruby versions or contexts, using 'item' from the outer loop#{' '}
              # inside a thread can lead to race conditions if not handled correctly.
              # Ensure each thread has its own snapshot of 'item'.
              threads = items.map do |item|
                Thread.new do
                  result = perform_work(item)
          #{'        '}
                  # BUG 3: Thread-unsafe mutation.
                  # Multiple threads are pushing to @results at the same time.
                  @results << result
                end
              end
              threads.each(&:join)
            end

            private

            def perform_work(item)
              # Simulate work that might fail
              raise "Critical Error" if item == "boom"
              "processed \#{item}"
            ensure
              # BUG 4: The ensure block must log the completion,#{' '}
              # but @logs is shared. Ensure this is thread-safe too.
              @logs << "Finished task at \#{Time.now}"
            end
          end

          # --- TEST SUITE ---

          # 1. Test Mutable Defaults
          p1 = JobProcessor.new
          p1.results << "fake"
          p2 = JobProcessor.new
          raise "Mutable Default Bug: Instances share state!" if p2.results.any?
          puts "✅ Mutable default fix passed"

          # 2. Test Concurrency & Scope
          processor = JobProcessor.new
          items = (1..100).to_a
          processor.process(items)

          raise "Thread Safety Bug: Lost data! Expected 100, got \#{processor.results.size}" if processor.results.size != 100
          puts "✅ Thread safety passed"

          # 3. Test Resilience (ensure)
          begin
            processor.process(["boom"])
          rescue
            # Expected error
          end
          raise "Resilience Bug: Ensure block didn't log the failure" if processor.logs.empty?
          puts "✅ Resilience (ensure) passed"

          puts "✨ KATA COMPLETE: You built a Resilient Processor!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. Mutable Default Arguments
          *Effective Ruby Item 13* - This is a legendary Ruby gotcha. When you write `def initialize(arr = [])`, the `[]` is evaluated once when the method is defined. All subsequent calls to `initialize` that rely on the default will share the **exact same Array instance**. If one instance modifies the array, all future instances will see those changes.
          *Expert Practice:* Use `def initialize(arr = nil); @arr = arr || []; end`.

          ### 2. The Closure Scope Trap
          In Ruby, blocks are closures—they capture the surrounding local variables by reference. When you spawn a `Thread.new` inside a loop, the thread's block might not run immediately. By the time it does, the loop variable (`item`) might have been updated by the next iteration.#{' '}
          *Expert Practice:* Always pass loop variables into `Thread.new` as arguments: `Thread.new(item) { |local_item| ... }`. This creates a local copy for that thread's block scope.

          ### 3. Thread-Safe Mutations (The Mutex)
          Ruby's GVL (Global VM Lock) prevents two threads from executing Ruby code at the same time in MRI, but it doesn't make operations like `array << value` atomic. Between reading the array length and writing the new value, another thread could context-switch in.
          *Expert Practice:* Protect any shared state mutation with a `Mutex`. A `Mutex#synchronize` block ensures that only one thread can access the protected resource at a time, preventing race conditions and data loss.

          ### 4. Exception Safety with `ensure`
          *Effective Ruby Item 22* - The `ensure` block is the only way to guarantee that code runs regardless of success or failure. In a resilient system, you use `ensure` to close network sockets, release file locks, or (as in this kata) ensure that audit logs are written even when a worker crashes. Without `ensure`, an unhandled exception would skip your cleanup/logging code.
        TEXT
      end
    end
  end
end
