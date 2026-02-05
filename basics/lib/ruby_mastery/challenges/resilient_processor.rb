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
          1. **Mutable Default Arguments**: *Effective Ruby Item 13* - `def initialize(arr = [])` evaluates `[]` once at definition time. Subsequent calls share the *same* array object. Always use `nil` and initialize inside the method.
          2. **Scope Gates & Threads**: Passing a loop variable into `Thread.new` without an argument can lead to the thread seeing the *latest* value of the variable instead of the value it had when the thread was created.
          3. **Shared State (Mutex)**: Any time multiple threads modify a shared object (like an Array), you must wrap the mutation in a `Mutex#synchronize` block to prevent data loss or corruption.
          4. **Exception Safety (`ensure`)**: This block is guaranteed to run even if an exception is raised, making it the perfect place for cleanup or logging.
        TEXT
      end
    end
  end
end
